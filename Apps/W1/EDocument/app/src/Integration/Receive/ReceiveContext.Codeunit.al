// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Receive;

using System.Utilities;
using Microsoft.eServices.EDocument.Integration.Action;
using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument;

codeunit 6186 ReceiveContext
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Retrieves the temporary blob used for storing E-Document content.
    /// </summary>
    procedure GetTempBlob(): Codeunit "Temp Blob"
    begin
        exit(this.TempBlob);
    end;

    /// <summary>
    /// Sets the temporary blob with the E-Document content.
    /// </summary>
    procedure SetTempBlob(TempBlob: Codeunit "Temp Blob")
    begin
        this.TempBlob := TempBlob;
    end;

    /// <summary>
    /// Sets the name of the E-Document content.
    /// </summary>
    procedure SetName(Name: Text[256])
    begin
        this.Name := Name;
    end;

    /// <summary>
    /// Retrieves the name of the E-Document content.
    /// </summary>
    internal procedure GetName(): Text[256]
    begin
        exit(this.Name);
    end;

    /// <summary>
    /// Retrieves the file format of the E-Document content.
    /// </summary>
    /// <returns></returns>
    internal procedure GetFileFormat(): Enum "E-Doc. File Format"
    begin
        exit(this.FileFormat);
    end;

    /// <summary>
    /// Sets the file format for the E-Document content.
    /// </summary>
    /// <param name="FileFormat"></param>
    procedure SetFileFormat(FileFormat: Enum "E-Doc. File Format")
    begin
        this.FileFormat := FileFormat;
    end;

    /// <summary>
    /// Get the Http Message State codeunit.
    /// </summary>
    procedure Http(): Codeunit "Http Message State"
    begin
        exit(this.HttpMessageState);
    end;

    /// <summary>
    /// Retrieves the Action Status object.
    /// </summary>
    procedure Status(): Codeunit "Integration Action Status"
    begin
        exit(this.IntegrationActionStatus);
    end;

    var
        TempBlob: Codeunit "Temp Blob";
        HttpMessageState: Codeunit "Http Message State";
        IntegrationActionStatus: Codeunit "Integration Action Status";
        FileFormat: Enum "E-Doc. File Format";
        Name: Text[256];

}
