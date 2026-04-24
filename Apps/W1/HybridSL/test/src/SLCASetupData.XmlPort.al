// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147637 "SL CASetup Data"
{
    Caption = 'SL CASetup data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL CASetup"; "SL CASetup")
            {
                AutoSave = false;
                XmlName = 'SLCASetup';

                textelement(SetupID)
                {
                }
                textelement(AcceptTransDate)
                {
                }
                textelement(ARHoldingAcct)
                {
                }
                textelement(ARHoldingSub)
                {
                }
                textelement(CurrPerNbr)
                {
                }
                textelement(PastStartDate)
                {
                }
                textelement(PerNbr)
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
                    SLCASetup: Record "SL CASetup";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLCASetup.SetupId := SetupID;
                    Evaluate(SLCASetup.AcceptTransDate, AcceptTransDate);
                    SLCASetup.ARHoldingAcct := ARHoldingAcct;
                    SLCASetup.ARHoldingSub := ARHoldingSub;
                    SLCASetup.CurrPerNbr := CurrPerNbr;
                    Evaluate(SLCASetup.PastStartDate, PastStartDate);
                    SLCASetup.PerNbr := PerNbr;
                    SLCASetup.Insert(true);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLCASetup.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLCASetup: Record "SL CASetup";
}