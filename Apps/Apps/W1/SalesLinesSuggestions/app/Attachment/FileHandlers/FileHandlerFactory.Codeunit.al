// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document.Attachment;

using System.IO;

codeunit 7294 "File Handler Factory"
{
    Access = Internal;

    procedure GetFileHandler(var FileParser: interface "File Handler"; FileName: Text)
    var
        FileManagement: Codeunit "File Management";
        FileParserType: Enum "File Handler Type";
    begin
        case FileManagement.GetFileNameMimeType(FileName) of
            'text/csv':
                FileParser := FileParserType::"CSV Handler";
            else
                Error('Unsupported file type');
        end;
    end;
}