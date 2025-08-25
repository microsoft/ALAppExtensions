// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147617 "SL ProductClass Data"
{
    Caption = 'SL ProductClass data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL ProductClass"; "SL ProductClass")
            {
                AutoSave = false;
                XmlName = 'SLProductClass';

                textelement(ClassId)
                {
                }
                textelement(Descr)
                {
                }
                textelement(DfltInvtAcct)
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
                    SLProductClass: Record "SL ProductClass";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLProductClass.ClassId := ClassId;
                    SLProductClass.Descr := Descr;
                    SLProductClass.DfltInvtAcct := DfltInvtAcct;
                    SLProductClass.Insert(true);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLProductClass.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLProductClass: Record "SL ProductClass";
}