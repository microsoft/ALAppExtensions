// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality to manage Print Shares.
/// </summary>
table 2752 "Universal Print Share Buffer"
{
    TableType = Temporary;
    ReplicateData = false;

    fields
    {

        /// <summary>
        /// The identifier of the print share.
        /// </summary>
        field(1; ID; Guid)
        {
            Caption = 'Print Share ID';
            NotBlank = true;
        }

        /// <summary>
        /// The name of the print share.
        /// </summary>
        field(2; "Name"; Text[2048])
        {
            Caption = 'Print Share Name';
            NotBlank = true;
        }
    }

    keys
    {
        key(PrimaryKey; ID)
        {
            Clustered = true;
        }
        key(Key2; "Name")
        {
        }
    }

    procedure FillRecordBuffer()
    var
        UniversalPrintShareBuffer: Record "Universal Print Share Buffer";
        UniversalPrinterSetup: Codeunit "Universal Printer Setup";
    begin
        UniversalPrintShareBuffer.CopyFilters(Rec);
        Reset();
        DeleteAll();
        UniversalPrinterSetup.AddAllPrintSharesToBuffer(Rec);
        CopyFilters(UniversalPrintShareBuffer);
        If Rec.FindFirst() then;
    end;
}