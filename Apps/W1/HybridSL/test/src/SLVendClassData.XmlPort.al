// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147614 "SL VendClass Data"
{
    Caption = 'SL VendClass data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL VendClass"; "SL VendClass")
            {
                AutoSave = false;
                XmlName = 'SLVendClass';

                textelement(ClassId)
                {
                }
                textelement(APAcct)
                {
                }
                textelement(Description)
                {
                }

                trigger OnPreXmlItem()
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;
                end;

                trigger OnBeforeInsertRecord()
                var
                    SLVendClass: Record "SL VendClass";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLVendClass.ClassId := ClassId;
                    SLVendClass.APAcct := APAcct;
                    SLVendClass.Descr := Description;
                    SLVendClass.Insert(true);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLVendClass.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLVendClass: Record "SL VendClass";
}