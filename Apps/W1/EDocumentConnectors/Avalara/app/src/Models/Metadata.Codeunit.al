// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara.Models;


/// <summary>
/// Construct meta data object for Avalara request
/// https://developer.avalara.com/api-reference/e-invoicing/einvoice/models/SubmitDocument/
/// </summary>
codeunit 6375 Metadata
{

    procedure SetWorkflowId(Id: Text): Codeunit Metadata
    begin
        this.WorkflowId := Id;
        exit(this);
    end;

    procedure SetDataFormat(Format2: Text): Codeunit Metadata
    begin
        this.Format := Format2;
        exit(this);
    end;

    procedure SetDataFormatVersion(Version: Text): Codeunit Metadata
    begin
        this.FormatVersion := Version;
        exit(this);
    end;

    procedure SetCountry(CountryCode2: Text): Codeunit Metadata
    begin
        this.CountryCode := CountryCode2;
        exit(this);
    end;

    procedure SetMandate(Mandate2: Text): Codeunit Metadata
    begin
        this.Mandate := Mandate2;
        exit(this);
    end;

    procedure ToString() Data: Text
    var
        JsonObject: JsonObject;
    begin
        JsonObject.Add('workflowId', this.WorkflowId);
        JsonObject.Add('dataFormat', this.Format);
        JsonObject.Add('dataFormatVersion', this.FormatVersion);
        JsonObject.Add('countryCode', this.CountryCode);
        JsonObject.Add('countryMandate', this.Mandate);
        JsonObject.WriteTo(Data);
    end;


    var
        WorkflowId, Format, FormatVersion, CountryCode, Mandate : Text;

}
