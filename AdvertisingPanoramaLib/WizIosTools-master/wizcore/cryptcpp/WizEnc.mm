//
//  WizEnc.cpp
//  WizNote
//
//  Created by WeiShijun on 13-4-15.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#include "WizEnc.h"
#import <cryptopp/modes.h>
#import <cryptopp/rsa.h>
#import <cryptopp/randpool.h>
#import <cryptopp/osrng.h>

#include <fstream>

#import "NSData+Base64.h"






bool WizStreamRead(std::istream& stream, char* pBuffer, int size) {
    stream.read((char *)pBuffer, size);
    return true;
}
bool WizStreamWrite(std::ostream& stream, const char* pBuffer, int size) {
    stream.write((const char *)pBuffer, size);
    return true;
}


class CAES
{
public:
	CAES()
	{
	}
public:
	~CAES()
	{
	}
    
public:
	/**
     init the enc/dec key.
     @param key the enc/dec key
     @param len the key length in bytes, this value can be 16, 24, 32 (128, 196, 256 bits) bytes
     @param iv block size 16 bytes initializaiton vector.
     */
	void init(const char * key, int len, const char * iv)
	{
		dec.SetKeyWithIV((const unsigned char *)key, len, (const unsigned char *)iv);
		memcpy(this->iv, iv, 16);
	}
    
	/**
     get the maximal cipher data length after encrypted.
     @param len the plain data length.
     @return the cipher data length.
     */
	int getCipherLen(int len)
	{
		// for PKCS#1 v1.5 padding
		// max padding BLOCK_SIZE=16.
		int pad = len%16;
		if (0 == pad)
		{
			return len + 16;
		}
		return len - pad + 16;
	}
    
	//
    
	/**
     the maximal plain data length after decrypted.
     @param len the cipher data length that will be decrypted.
     @return the maximal plain data length.
     */
	int getPlainLen(int len)
	{
		// for PKCS#1 v1.5 padding
		// len always be times of BLOCK_SIZE=16.
		return len;
	}
    
    
	int decrypt(std::istream& src, int srcSize, std::ostream& dest)
	{
		// resynchronize with an IV
		dec.Resynchronize((const unsigned char *)iv);
		//
		char* pBufferSrc = NULL;
		char* pBufferDest = NULL;
		//
		BOOL bRet = FALSE;
		//
		try
		{
			int nSrcLen = srcSize;
			if (nSrcLen % 16 != 0)
			{
				throw std::exception();
			}
			//
			const unsigned int BLOCK_SIZE = 1024 * 16;
			//
			pBufferSrc = new char[BLOCK_SIZE];
			if (!pBufferSrc)
				throw std::exception();
			//
			pBufferDest = new char[BLOCK_SIZE];
			if (!pBufferDest)
				throw std::exception();
			//
			//
			// process normal prefix blocks.
			int prefix = nSrcLen - 16;
			if (prefix > 0)
			{
				int nBlockCount = prefix / BLOCK_SIZE;
				//
				for (int i = 0; i < nBlockCount; i++)
				{
					if (!WizStreamRead(src, pBufferSrc, BLOCK_SIZE))
						throw std::exception();
					dec.ProcessData((unsigned char*)pBufferDest, (const unsigned char*)pBufferSrc, BLOCK_SIZE);
					if (!WizStreamWrite(dest, pBufferDest, BLOCK_SIZE))
						throw std::exception();
				}
				//
				int nLast = prefix % BLOCK_SIZE;
				if (nLast > 0)
				{
					//
					if (!WizStreamRead(src, pBufferSrc, nLast))
						throw std::exception();
					dec.ProcessData((unsigned char*)pBufferDest, (const unsigned char*)pBufferSrc, nLast);
					if (!WizStreamWrite(dest, pBufferDest, nLast))
						throw std::exception();
				}
			}
			//
			unsigned char padding[16];
			if (!WizStreamRead(src, pBufferSrc, 16))
				throw std::exception();
			dec.ProcessLastBlock(padding, (const unsigned char*)pBufferSrc, 16);
			int pad = padding[15];
			if (pad > 16)
				throw std::exception();
			//
			for (int i = 0; i < pad; i++)
			{
				if (padding[15 - i] != pad)
					throw std::exception();
			}
			//
			if (!WizStreamWrite(dest, (const char*)padding, 16 - pad))
				throw std::exception();
			//
			bRet = TRUE;
		}
		catch (const std::exception& err)
		{
		}
		//
		delete [] pBufferSrc;
		delete [] pBufferDest;
		//
		if (!bRet)
			return -1;
		//
        return 0;
	}
    
	/**
     decrypt the indata to outdata.
     @param indata the input data to be encrypted.
     @param inlen the input data length in bytes, must be times of 16 bytes.
     @param outdata the output data, at least the length with input data.
     */
	int decrypt(const unsigned char * indata, int inlen, unsigned char * outdata)
	{
		// drop no times of 16 bytes data.
		inlen -= inlen%16;
		if (inlen < 16)
		{
			return 0;
		}
        
		// resynchronize with an IV
		dec.Resynchronize((const unsigned char *)iv);
        
		// process normal prefix blocks.
		int prefix = inlen - 16;
		if (prefix > 0)
		{
			dec.ProcessData((unsigned char *)outdata, (const unsigned char *)indata, prefix);
		}
        
		// process padding block.
		char padding[16];
		dec.ProcessLastBlock((unsigned char *)padding, (const unsigned char *)(indata+prefix), 16);
        
		int pad = (unsigned char)padding[15];
		if (pad < 16)
		{
			memcpy(outdata+prefix, padding, 16-pad);
		}
        
		return prefix + 16 - pad;
	}
    
private:
	CryptoPP::CBC_Mode<CryptoPP::AES>::Decryption dec;   // cryptopp implement aes CBC decryptor.
	char iv[16];   // initialization vector.
};


bool WizAES_CBC_ProcessKey(const char* lpszKey, int nKeyLen, std::string& strKey)
{
	if (!lpszKey || nKeyLen <= 0)
	{
		//TOLOG(_T("Key is empty"));
		return false;
	}
    //
    NSString* md5 = [WizGlobals md5CString:lpszKey];;
    
    strKey = [md5 UTF8String];
	//
	return true;
}

int WizToolsDecrypt_AES256_CBC_PKCS5(const char* lpszKey, int nKeyLen, const char* pIV, int nIVLen, std::istream& src, int srcSize, std::ostream& dest)
{
	if (!pIV)
	{
		return -1;
	}
	if (nIVLen != 16)
	{
		return -1;
	}
	//
    std::string strKey;
	if (!WizAES_CBC_ProcessKey(lpszKey, nKeyLen, strKey))
	{
		return -1;
	}
	//
	// init AES.
	CAES aes;
	aes.init(strKey.c_str(), strKey.size(), pIV);
	//
	// encrypt.
	return aes.decrypt(src, srcSize, dest);
}


int WizToolsDecrypt_AES256_CBC_PKCS5(const char* lpszKey, int nKeyLen, const char* pIV, int nIVLen, const unsigned char* src, int srcSize, unsigned char* dest)
{
	if (!pIV)
	{
		return -1;
	}
	if (nIVLen != 16)
	{
		return -1;
	}
	//
    std::string strKey;
	if (!WizAES_CBC_ProcessKey(lpszKey, nKeyLen, strKey))
	{
		return -1;
	}
	//
	// init AES.
	CAES aes;
	aes.init(strKey.c_str(), strKey.size(), pIV);
	//
	// encrypt.
	return aes.decrypt(src, srcSize, dest);
}







class CRSA
{
private:
	CryptoPP::RSAFunction pk;  // public key.
	CryptoPP::InvertibleRSAFunction sk;    // private key.
	CryptoPP::RSAES_PKCS1v15_Decryptor * dec;    // decryptor.
	CryptoPP::AutoSeededRandomPool rng;        // auto seeded randomor.
public:
	CRSA()
	{
		dec = NULL;
	}
    
	~CRSA()
	{
		if (NULL != dec)
		{
			delete dec;
			dec = NULL;
		}
	}
    
	void initPublicKey(const char * N, const char * e)
	{
		CryptoPP::Integer big_N(N);
		CryptoPP::Integer big_e(e);
        
		pk.Initialize(big_N, big_e);
	}
    
	void initPrivateKey(const char * N, const char * e, const char * d)
	{
		CryptoPP::Integer big_N(N);
		CryptoPP::Integer big_e(e);
		CryptoPP::Integer big_d(d);
        
		sk.Initialize(big_N, big_e, big_d);
		if (NULL != dec)
		{
			delete dec;
		}
		dec = new CryptoPP::RSAES_PKCS1v15_Decryptor(sk);
	}
    
    
	int getPlainLen(int len)
	{
		return (int)dec->MaxPlaintextLength(len);
	}
    
	int decrypt(const char * indata, int len, char * outdata)
	{
		const CryptoPP::DecodingResult & res = dec->Decrypt(rng, (const unsigned char *)indata, len, (unsigned char *)outdata);
		return (int)res.messageLength;
	}
};

int WizToolsDecrypt_RSA(const char* N, const char* e, const char* d, const char* src, unsigned int srcSize, char* dest, int destSize)
{
	int nSrcLen = (int)srcSize;
	if (nSrcLen > 256)
	{
		return -1;
	}
    //
	CRSA enc;
	try
	{
		enc.initPrivateKey(N, e, d);
	}
	catch (std::exception& e)
	{
		return -1;
	}
	//
	if (enc.getPlainLen(nSrcLen) > 117)
	{
		return -1;
	}
	//
	int nRetLen = enc.decrypt(src, nSrcLen, dest);
    if (nRetLen <= 0)
        return -1;
    //
    return nRetLen;
}

int WizToolsSimpleDecryptRSA(const char* N, const char* e, const char* d, const char* src, unsigned int srcSize, char* dest)
{
    return WizToolsDecrypt_RSA(N, e, d, src, srcSize, dest, 255);
}


int WizToolsSimpleDecryptAES(const char* lpszFileNameSrc, const char* lpszFileNameDest, const char* password)
{
    NSInteger it = [WizGlobals fileLength:[NSString stringWithUTF8String:lpszFileNameSrc]];
    //
    int srcSize = it;
    //
    std::ifstream src(lpszFileNameSrc, std::ios::in | std::ios::binary);
    if (src.bad())
        return -1;
    //
    std::ofstream dest(lpszFileNameDest, std::ios::out | std::ios::binary);
    if (dest.bad())
        return -1;
    //
    return WizToolsDecrypt_AES256_CBC_PKCS5(password, (int)strlen(password), "0123456789abcdef", 16, src, srcSize, dest);
}

int WizToolsSimpleDecryptAES(const char* src, int srcSize, char* dest, const char* password)
{
    return WizToolsDecrypt_AES256_CBC_PKCS5(password, (int)strlen(password), "0123456789abcdef", 16, (const unsigned char*)src, srcSize, (unsigned char*)dest);
}


int WizToolsSimpleDecryptAES(std::istream& src, int srcSize, std::ostream& dest, const char* password)
{
    return WizToolsDecrypt_AES256_CBC_PKCS5(password, (int)strlen(password), "0123456789abcdef", 16, src, srcSize, dest);
}



#pragma pack(1)

#define WIZKMZIWFILE_SIGN_LENGTH			4
#define WIZKMZIWFILE_KEY_LENGTH				128
#define WIZKMZIWFILE_RESERVED_LENGTH		16

struct WIZKMZIWHEADER
{
	char szSign[4];
	unsigned int nVersion;
	unsigned int nKeyLength;
	char szEncryptedKey[WIZKMZIWFILE_KEY_LENGTH];
	char szReserved[WIZKMZIWFILE_RESERVED_LENGTH];
};

#pragma pack()





enum WizKMZiwFileType
{
	ziwUnknown = -1,
	ziwZip = 0,
	ziwRSA = 1,
	ziwAES = 2,
};




static WizKMZiwFileType GetZiwFileTypeFromSign(char szSign[WIZKMZIWFILE_SIGN_LENGTH])
{
    if (szSign[0] == 'P' && szSign[1] == 'K')
        return ziwZip;
    else if (szSign[0] == 'Z' && szSign[1] == 'I' && szSign[2] == 'W')
    {
        if (szSign[3] == 'R')
            return ziwRSA;
        else if (szSign[3] == 'A')
            return ziwAES;
    }
    //
    return ziwUnknown;
}
static WizKMZiwFileType GetZiwFileType(const char* lpszFileName)
{
    FILE* fp = fopen(lpszFileName, "rb");
    if (!fp)
    {
        return ziwUnknown;
    }
    //
    char szSign[WIZKMZIWFILE_SIGN_LENGTH];
    memset(szSign, 0, WIZKMZIWFILE_SIGN_LENGTH);
    fread(szSign, WIZKMZIWFILE_SIGN_LENGTH, 1, fp);
    //
    fclose(fp);
    //
    return GetZiwFileTypeFromSign(szSign);
}

BOOL IsWizKMZiwFileEnrypt(NSString* filePath)
{
    if (GetZiwFileType([filePath UTF8String]) != ziwZip) {
        return YES;
    }
    else
    {
        return NO;
    }
}

extern "C" enum WizDecryptZiwResult WizDecryptZiw(const char* N, const char* e, const char* decrypted_d, const char* password, const char* encryptedZiwFileName, const char* decryptedZiwFileName)
{
    if (!N)
        return wizInvalidArguments;
    if (!e)
        return wizInvalidArguments;
    if (!decrypted_d)
        return wizInvalidArguments;
    if (!password)
        return wizInvalidArguments;
    if (!encryptedZiwFileName)
        return wizInvalidArguments;
    if (!decryptedZiwFileName)
        return wizInvalidArguments;

    NSData* dataEncrypted_d = [NSData dataFromBase64String:[NSString stringWithUTF8String:decrypted_d]];
    //
    int nEncrypted_d_Size = [dataEncrypted_d length];
    const char* bufferEncrypted_d = (const char*)[dataEncrypted_d bytes];
    //
    char d[1024] = {0};
    memset(d, 0, 1024);
    if (WizToolsSimpleDecryptAES(bufferEncrypted_d, nEncrypted_d_Size, d, password) <= 0)
        return  wizInvalidPassword;
    //
    int nFileSize = [WizGlobals fileLength:[NSString stringWithUTF8String:encryptedZiwFileName]];
    //
    std::ifstream src(encryptedZiwFileName, std::ios::in | std::ios::binary);
    if (src.bad())
        return wizCannotOpenSrcFile;
    //
    WizKMZiwFileType filetype = ziwUnknown;
    WIZKMZIWHEADER header;
    //
    memset(&header, 0, sizeof(WIZKMZIWHEADER));
    WizStreamRead(src, (char*)&header, sizeof(WIZKMZIWHEADER));
    //
    filetype = GetZiwFileTypeFromSign(header.szSign);
    //
    if (ziwRSA != filetype)
        return wizNotEncrypted;
    //
    int nDataSize = (int)nFileSize - sizeof(WIZKMZIWHEADER);
    //
    char szKey[255];
    memset(szKey, 0, 255);
    int keyLen = WizToolsSimpleDecryptRSA(N, e, d, header.szEncryptedKey, header.nKeyLength, szKey);
    if (keyLen <= 0)
        return wizInvalidPassword;
    szKey[keyLen] = 0;
    
    
    
    //
    std::ofstream dest(decryptedZiwFileName, std::ios::out | std::ios::binary);
    if (dest.bad())
        return wizCannotWriteFile;
    //
    
    int ret = WizToolsSimpleDecryptAES(src, nDataSize, dest, szKey);
    //
    if (0 != ret)
        return wizUnknownError;
    //
    return wizDone;
}


extern "C" enum WizDecryptZiwResult WizDecryptZiw_NS(NSString* n, NSString* e, NSString* decrypted_d, NSString* password, NSString* encryptedZiwFileName, NSString* decryptedZiwFileName)
{
    return WizDecryptZiw([n UTF8String], [e UTF8String], [decrypted_d UTF8String], [password UTF8String], [encryptedZiwFileName UTF8String], [decryptedZiwFileName UTF8String]);
}





