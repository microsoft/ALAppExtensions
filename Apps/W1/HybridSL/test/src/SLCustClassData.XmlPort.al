// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147611 "SL CustClass Data"
{
    Caption = 'SL CustClass data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL CustClass"; "SL CustClass")
            {
                AutoSave = false;
                XmlName = 'SLCustClass';

                textelement(ClassId)
                {
                }
                textelement(ArAcct)
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
                    SLCustClass: Record "SL CustClass";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLCustClass.ClassId := ClassId;
                    SLCustClass.ARAcct := ArAcct;
                    SLCustClass.Descr := Description;
                    SLCustClass.Insert(true);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLCustClass.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLCustClass: Record "SL CustClass";
}
