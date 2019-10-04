#include <efi.h>
#include <efilib.h>

struct efi_variable {
	CHAR16 name[1024 / sizeof(CHAR16)];
	EFI_GUID guid;
	UINT32 attr;
};

#define EFI_MAX_CER_SIZE 30 * 1024
#define CERT_ATTR EFI_VARIABLE_NON_VOLATILE | EFI_VARIABLE_BOOTSERVICE_ACCESS | EFI_VARIABLE_RUNTIME_ACCESS | EFI_VARIABLE_TIME_BASED_AUTHENTICATED_WRITE_ACCESS
#define EFI_SIG_DB { 0xd719b2cb, 0x3d3a, 0x4596, {0xa3, 0xbc, 0xda, 0xd0,  0xe, 0x67, 0x65, 0x6f} }

static const struct efi_variable EFI_PK = { L"PK", EFI_GLOBAL_VARIABLE, CERT_ATTR };
static const struct efi_variable EFI_KEK = { L"KEK", EFI_GLOBAL_VARIABLE, CERT_ATTR };
static const struct efi_variable EFI_DB = { L"db", EFI_SIG_DB, CERT_ATTR };

static UINT32 calc_crc32(UINTN size, const UINT8* data)
{

	if (!size | !data) {
		Print(L"calc_crc32: invalid input\n");
		return 0;
	}

	EFI_STATUS r = EFI_INVALID_PARAMETER;
	UINT32 crc32 = 0;

	r = uefi_call_wrapper(BS->CalculateCrc32, 3, data, size, &crc32);
	if (EFI_ERROR(r)) {
		Print(L"calc_crc32: failed: %r\n", r);
	}

	return crc32;
}

static EFI_STATUS
check_variable(const struct efi_variable* var, UINT32* crc32)
{
	if (!var) {
		Print(L"check_variable: invalid input\n");
		return EFI_INVALID_PARAMETER;
	}

	EFI_STATUS r = EFI_INVALID_PARAMETER;
	UINT8 data[EFI_MAX_CER_SIZE];
	UINTN size = EFI_MAX_CER_SIZE;
	UINT32 attr;

	r = uefi_call_wrapper(RT->GetVariable, 5,
							var->name, &var->guid, &attr, &size, data);

	if (EFI_ERROR(r)) {
		Print(L"var: %s: read failed: %r\n", var->name, r);
		return r;
	}

	*crc32 = calc_crc32(size, data);
	Print(L"var: %s: attr: 0x%x: read %d bytes: crc32: %d\n", var->name, attr, size, *crc32);

	return EFI_SUCCESS;
}

static EFI_STATUS
write_variable(const struct efi_variable* var, UINTN size, UINT8* data)
{
	if (!var | !size | !data) {
		Print(L"write: invalid input\n");
		return EFI_INVALID_PARAMETER;
	}

	EFI_STATUS r = EFI_INVALID_PARAMETER;

	r = uefi_call_wrapper(RT->SetVariable, 5,
							var->name, &var->guid, var->attr, size, data);
	if (EFI_ERROR(r)) {
		Print(L"var: %s: write failed: %r\n", var->name, r);
		return r;
	}

	return EFI_SUCCESS;
}

static EFI_STATUS
open_file(EFI_HANDLE image, const CHAR16* file, EFI_FILE_HANDLE* fp, UINT64 mode)
{
	if (!image | !file) {
		Print(L"read_cert: invalid input\n");
		return EFI_INVALID_PARAMETER;
	}

	EFI_STATUS r = EFI_INVALID_PARAMETER;
	EFI_LOADED_IMAGE *li = NULL;
	EFI_FILE_IO_INTERFACE *vol = NULL;
	EFI_FILE_HANDLE cur = NULL;
	EFI_GUID loaded_image = LOADED_IMAGE_PROTOCOL;
	EFI_GUID simple_filefs = SIMPLE_FILE_SYSTEM_PROTOCOL;

	r = uefi_call_wrapper(BS->HandleProtocol, 3, image, &loaded_image, (void **) &li);
	if (EFI_ERROR(r)) {
		Print(L"open_file: %s: HandleProtocol: %g: failed: %r\n", file, &loaded_image, r);
		return r;
	}

	r = uefi_call_wrapper(BS->HandleProtocol, 3, li->DeviceHandle, &simple_filefs, (void **) &vol);
	if (EFI_ERROR(r)) {
		Print(L"open_file: %s: HandleProtocol: %g: failed: %r\n", file, &simple_filefs, r);
		return r;
	}

	r = uefi_call_wrapper(vol->OpenVolume, 2, vol, &cur);
	if (EFI_ERROR(r)) {
		Print(L"open_file: %s: OpenVolume failed: %r\n", file, r);
		return r;
	}

	r = uefi_call_wrapper(cur->Open, 5, cur, fp, file, mode, 0);
	if (EFI_ERROR(r)) {
		Print(L"open_file: %s: Open failed: %r\n", file, r);
		return r;
	}

	return EFI_SUCCESS;
}

static EFI_STATUS
close_file(EFI_FILE_HANDLE fp)
{
	if (!fp) {
		Print(L"close_file: invalid input\n");
		return EFI_INVALID_PARAMETER;
	}

	EFI_STATUS r = EFI_INVALID_PARAMETER;

	r = uefi_call_wrapper(fp->Close, 1, fp);
	if (EFI_ERROR(r)) {
		Print(L"close_file: Close failed: %r\n", r);
		return r;
	}

	return EFI_SUCCESS;
}

static EFI_STATUS
read_file(EFI_FILE_HANDLE fp, UINTN* size, void* data)
{
	if (!fp | !size | !data) {
		Print(L"read_file: invalid input\n");
		return EFI_INVALID_PARAMETER;
	}

	EFI_STATUS r = EFI_INVALID_PARAMETER;

	r = uefi_call_wrapper(fp->Read, 3, fp, size, data);
	if (EFI_ERROR(r)) {
		Print(L"read_file: Read failed: %r\n", r);
		return r;
	}

	return EFI_SUCCESS;
}

static EFI_STATUS
read_write_read_var(EFI_HANDLE image, const struct efi_variable* var, CHAR16* cer_file)
{
	if (!image | !var | !cer_file) {
		Print(L"read_write_read_var: invalid input\n");
		return EFI_INVALID_PARAMETER;
	}

	EFI_STATUS r = EFI_INVALID_PARAMETER;
	UINT8 cer_buf[EFI_MAX_CER_SIZE];
	UINTN cer_size = EFI_MAX_CER_SIZE;
	EFI_FILE_HANDLE fp = NULL;
	UINT32 crc32_before = 0;
	UINT32 crc32_after = 0;

	check_variable(var, &crc32_before);

	r = open_file(image, cer_file, &fp, EFI_FILE_MODE_READ);
	if (EFI_ERROR(r)) {
		return r;
	}

	r = read_file(fp, &cer_size, cer_buf);
	close_file(fp);
	if (EFI_ERROR(r)) {
		return r;
	}

	r = write_variable(var, cer_size, cer_buf);
	Print(L"var: %s: write_variable: return %r\n", var->name, r);

	r = check_variable(var, &crc32_after);
	if (EFI_ERROR(r)) {
		return r;
	}

	if (crc32_before == crc32_after) {
		Print(L"var: %s: identical before and after write\n", var->name);
	}

	return EFI_SUCCESS;
}

EFI_STATUS
EFIAPI
efi_main (EFI_HANDLE image, EFI_SYSTEM_TABLE *sys_table) {

	EFI_STATUS r = EFI_SUCCESS;

	InitializeLib(image, sys_table);

	Print(L"\n");
	r += read_write_read_var(image, &EFI_PK, L"PK.sig");
	Print(L"\n");
	r += read_write_read_var(image, &EFI_KEK, L"KEK.sig");
	Print(L"\n");
	r += read_write_read_var(image, &EFI_DB, L"DB.sig");

	return r;
}

