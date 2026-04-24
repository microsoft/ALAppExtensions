// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147647 "SL INUnit Data"
{
    Caption = 'SL INUnit data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL INUnit"; "SL INUnit")
            {
                AutoSave = false;
                XmlName = 'SLINUnit';

                textelement(UnitType)
                {
                }
                textelement(ClassID)
                {
                }
                textelement(InvtID)
                {
                }
                textelement(FromUnit)
                {
                }
                textelement(ToUnit)
                {
                }
                textelement(CnvFact)
                {
                }
                textelement(MultDiv)
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
                    SLINUnit: Record "SL INUnit";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    Evaluate(SLINUnit.UnitType, UnitType);
                    SLINUnit.ClassID := ClassID;
                    SLINUnit.InvtID := InvtID;
                    SLINUnit.FromUnit := FromUnit;
                    SLINUnit.ToUnit := ToUnit;
                    Evaluate(SLINUnit.CnvFact, CnvFact);
                    SLINUnit.MultDiv := MultDiv;
                    SLINUnit.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLINUnit.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLINUnit: Record "SL INUnit";
}