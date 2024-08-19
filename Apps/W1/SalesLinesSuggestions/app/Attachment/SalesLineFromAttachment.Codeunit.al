// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document.Attachment;

using Microsoft.Sales.Document;
using System.AI;
using System.IO;
using System.Utilities;

codeunit 7292 "Sales Line From Attachment"
{
    Access = Internal;

    var
        SupportedFileFilterCaptionLbl: Label 'csv files (*.csv)|*.csv', Locked = true;
        SupportedFileFilterLbl: Label '*.csv', Locked = true;
        FileUploadCaptionLbl: Label 'Select a file to upload';

    internal procedure AttachAndSuggest(SalesHeader: Record "Sales Header")
    begin
        AttachAndSuggest(SalesHeader, PromptMode::Generate);
    end;

    internal procedure AttachAndSuggest(SalesHeader: Record "Sales Header"; NewMode: PromptMode)
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        FileHandlerFactory: Codeunit "File Handler Factory";
        TempBlob: Codeunit "Temp Blob";
        SalesLineFromAttachment: Page "Sales Line From Attachment";
        FileHandler: interface "File Handler";
        FileName: Text;
    begin
        SalesHeader.TestStatusOpen();
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Sales Lines Suggestions") then
            exit;

        if Upload(TempBlob, FileName) then begin
            if FileName = '' then
                exit;
            FileHandlerFactory.GetFileHandler(FileHandler, FileName);

            SalesLineFromAttachment.LoadData(FileHandler, FileName, TempBlob, SalesHeader);
            SalesLineFromAttachment.SetPromptMode(NewMode);
            SalesLineFromAttachment.Run();
        end;
    end;

    internal procedure AttachAndSuggest(SalesHeader: Record "Sales Header"; NewMode: PromptMode; TempBlob: Codeunit "Temp Blob"; FileName: Text)
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        FileHandlerFactory: Codeunit "File Handler Factory";
        SalesLineFromAttachment: Page "Sales Line From Attachment";
        FileHandler: interface "File Handler";
    begin
        SalesHeader.TestStatusOpen();
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Sales Lines Suggestions") then
            exit;

        if FileName = '' then
            exit;
        FileHandlerFactory.GetFileHandler(FileHandler, FileName);

        SalesLineFromAttachment.LoadData(FileHandler, FileName, TempBlob, SalesHeader);
        SalesLineFromAttachment.SetPromptMode(NewMode);
        SalesLineFromAttachment.Run();
    end;

    internal procedure AttachAndSuggest(SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
            AttachAndSuggest(SalesHeader);
    end;

    [TryFunction]
    local procedure Upload(var TempBlob: Codeunit "Temp Blob"; var FileName: Text)
    var
        FileManagement: Codeunit "File Management";
    begin
        Clear(TempBlob);

        FileName := FileManagement.BLOBImportWithFilter(TempBlob, FileUploadCaptionLbl, FileName, SupportedFileFilterCaptionLbl, SupportedFileFilterLbl);
    end;

    internal procedure GetMaxPromptSize(): Integer
    begin
        exit(10000);
    end;

    internal procedure GetMaxRowsToShow(): Integer
    begin
        exit(50);
    end;
}