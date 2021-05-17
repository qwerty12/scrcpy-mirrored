#include "stdafx.h"

static CONST UINT SDL_FLIP_HORIZONTAL = 0x00000001;

static INT (* ChromeStart)(VOID) = NULL;
static INT(_cdecl* SDL_RenderCopyEx)(LPVOID, LPVOID, LPCVOID, LPCVOID, CONST double, LPCVOID, const UINT) = NULL;

INT _cdecl SDL_RenderCopyExDetoured(LPVOID renderer,
	LPVOID texture,
	LPCVOID srcrect,
	LPCVOID dstrect,
	CONST double angle,
	LPCVOID center,
	const UINT flip)
{
	UNREFERENCED_PARAMETER(flip);
	return SDL_RenderCopyEx(renderer, texture, srcrect, dstrect, angle, center, SDL_FLIP_HORIZONTAL);
}

INT __cdecl SDL_RenderCopyDetoured(LPVOID renderer,
	LPVOID texture,
	LPCVOID srcrect,
	LPCVOID dstrect)
{
	//unsigned rotation = (*(unsigned*)((UINT_PTR)dstrect - sizeof(unsigned)));
	return SDL_RenderCopyEx(renderer, texture, srcrect, dstrect, 0, NULL, SDL_FLIP_HORIZONTAL);
}

INT DetouredStart()
{
	HMODULE hmodSdl = GetModuleHandleW(L"SDL2.dll");
	LPVOID SDL_RenderCopy = GetProcAddress(hmodSdl, "SDL_RenderCopy");
	*(FARPROC*)&SDL_RenderCopyEx = GetProcAddress(hmodSdl, "SDL_RenderCopyEx");

	DetourTransactionBegin();
	DetourUpdateThread(GetCurrentThread());
	DetourAttach((PVOID*)&SDL_RenderCopy, (PVOID)SDL_RenderCopyDetoured); // screen->rotation == 0
	DetourAttach((PVOID*)&SDL_RenderCopyEx, (PVOID)SDL_RenderCopyExDetoured); // screen->rotation != 0
	DetourTransactionCommit();
	
	return ChromeStart();
}

VOID loader_init()
{
	if ((ChromeStart = DetourGetEntryPoint(NULL))) {
		DetourTransactionBegin();
		DetourUpdateThread(GetCurrentThread());
		DetourAttach((PVOID*)&ChromeStart, (PVOID)DetouredStart);
		DetourTransactionCommit();
	}
}