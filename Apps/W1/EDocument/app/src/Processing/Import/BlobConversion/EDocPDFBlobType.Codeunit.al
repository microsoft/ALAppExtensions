// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using System.Utilities;
using System.Text;
// using System.Azure.DI;

/// <summary>
/// E-Document OCR Converter
/// Converts a binary unstructured blob to a structured type such as JSON using OCR.
/// </summary>
codeunit 6173 "E-Doc. PDF Blob Type" implements IBlobType, IBlobToStructuredDataConverter
{
    Access = Internal;

    procedure IsStructured(): Boolean
    begin
        exit(false);
    end;

    procedure HasConverter(): Boolean
    begin
        exit(true);
    end;

    procedure GetStructuredDataConverter(): Interface IBlobToStructuredDataConverter
    begin
        exit(this);
    end;

    procedure Convert(EDocument: Record "E-Document"; FromTempblob: Codeunit "Temp Blob"; FromType: Enum "E-Doc. Data Storage Blob Type"; var ConvertedType: Enum "E-Doc. Data Storage Blob Type") StructuredData: Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        // AzureDI: Codeunit "Azure DI";
        Instream: InStream;
        Data: Text;
    begin
        // Debug
        // StructuredData := NavApp.GetResourceAsText('Test.json', TextEncoding::UTF8);
        // ConvertedType := Enum::"E-Doc. Data Storage Blob Type"::JSON;

        FromTempblob.CreateInStream(InStream, TextEncoding::UTF8);
        Data := Base64Convert.ToBase64(InStream);

        // StructuredData := AzureDI.AnalyzeInvoice(Data);
        StructuredData := '';
        ConvertedType := Enum::"E-Doc. Data Storage Blob Type"::JSON;
    end;

    // TODO: Awaiting uptake in SystemModule. Then uncomment code.

}