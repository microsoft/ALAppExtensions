// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document.Attachment;

using System.Security.Encryption;
codeunit 7297 "Mapping Cache Management"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    internal procedure MappingExists(FileIdentityHash: Text): Boolean
    var
        MappingCache: Record "Mapping Cache";
    begin
        exit(MappingCache.Get(FileIdentityHash));
    end;

    internal procedure GetMapping(FileIdentityHash: Text; var SavedMappingAsText: Text): Boolean
    var
        MappingCache: Record "Mapping Cache";
        InStream: InStream;
        StreamLength: Integer;
    begin
        if MappingCache.Get(FileIdentityHash) then begin
            MappingCache.CalcFields(Mapping);
            if not MappingCache.Mapping.HasValue then begin
                MappingCache.Delete();
                exit(false);
            end;
            MappingCache.Mapping.CreateInStream(InStream, TextEncoding::UTF8);
            StreamLength := InStream.ReadText(SavedMappingAsText);
            if (StreamLength <= 0) or (SavedMappingAsText = '') then begin
                MappingCache.Delete();
                exit(false);
            end;
            exit(true);
        end;
        exit(false);
    end;

    internal procedure SaveMapping(FileIdentityHash: Text; MappingAsText: Text)
    var
        MappingCache: Record "Mapping Cache";
        OutStream: OutStream;
    begin
        if MappingCache.Get(FileIdentityHash) then begin
            Clear(MappingCache.Mapping);
            MappingCache.Mapping.CreateOutStream(OutStream, TextEncoding::UTF8);
            OutStream.WriteText(MappingAsText);
            MappingCache.Modify();
        end else begin
            if not MappingCache.WritePermission then
                exit;
            MappingCache.Init();
            MappingCache."File Identity Hash" := CopyStr(FileIdentityHash, 1, MaxStrLen(MappingCache."File Identity Hash"));
            MappingCache.Mapping.CreateOutStream(OutStream);
            OutStream.WriteText(MappingAsText);
            MappingCache.Insert();
        end;
    end;

    internal procedure GenerateFileHashInHex(TextToHash: Text): Text[1024]
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
    begin
        exit(CopyStr(CryptographyManagement.GenerateHash(TextToHash, HashAlgorithmType::SHA256), 1, 1024));
    end;
}