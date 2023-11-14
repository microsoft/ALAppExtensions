// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using System.IO;
using System.Utilities;

report 31106 "Import Tariff Numbers XML CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Import Tariff Numbers (XML)';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(FileName_Var; FileName)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'File Name';
                        ToolTip = 'Specifies the xml file name for tariff number import.';
                        ShowMandatory = true;

                        trigger OnAssistEdit()
                        begin
                            ImportLocalFile();
                        end;
                    }
                    field(ValidToDate_Var; ValidToDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Valid-to Date';
                        ToolTip = 'Specifies valid to date';
                        ShowMandatory = true;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        if FileName = '' then
            Error(FileNameErr);

        if TempBlob.Length() = 0 then
            ImportLocalFile();

        TempBlob.CreateInStream(FileInStream);

        ImportTariffNumbersCZL.SetSource(FileInStream);
        ImportTariffNumbersCZL.SetThresholdDate(ValidToDate);
        ImportTariffNumbersCZL.Import();
    end;

    var
        TempBlob: Codeunit "Temp Blob";
        ImportTariffNumbersCZL: XmlPort "Import Tariff Numbers CZL";
        FileInStream: InStream;
        ValidToDate: Date;
        FileName: Text;
        FileNameErr: Label 'You must enter file name!';
        ImportFromXmlFileTxt: Label 'Select the xml file name for tariff number import.';

    local procedure ImportLocalFile()
    var
        FileManagement: Codeunit "File Management";

    begin
        FileName := FileManagement.BLOBImportWithFilter(
            TempBlob, ImportFromXmlFileTxt, FileName, FileManagement.GetToFilterText('', '.xml'), '*.*');
    end;
}

