// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147600 "SL Customer Data"
{
    Caption = 'SL Customer data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL Customer"; "SL Customer")
            {
                AutoSave = false;
                XmlName = 'SLCustomer';

                textelement(CustID)
                {
                }
                textelement(Addr1)
                {
                }
                textelement(Addr2)
                {
                }
                textelement(Attn)
                {
                }
                textelement(BillName)
                {
                }
                textelement(City)
                {
                }
                textelement(ClassId)
                {
                }
                textelement(Country)
                {
                }
                textelement(CrLmt)
                {
                }
                textelement(DfltShipToId)
                {
                }
                textelement(Fax)
                {
                }
                textelement(Name)
                {
                }
                textelement(Phone)
                {
                }
                textelement(SlsperId)
                {
                }
                textelement(State)
                {
                }
                textelement(Status)
                {
                }
                textelement(TaxID00)
                {
                }
                textelement(Terms)
                {
                }
                textelement(Territory)
                {
                }
                textelement(Zip)
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
                    SLCustomer: Record "SL Customer";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLCustomer.CustId := CustId;
                    SLCustomer.Addr1 := Addr1;
                    SLCustomer.Addr2 := Addr2;
                    SLCustomer.Attn := Attn;
                    SLCustomer.BillName := BillName;
                    SLCustomer.City := City;
                    SLCustomer.ClassId := ClassId;
                    SLCustomer.Country := Country;
                    Evaluate(SLCustomer.CrLmt, CrLmt, 9);
                    SLCustomer.DfltShipToId := DfltShipToId;
                    SLCustomer.Fax := Fax;
                    SLCustomer.Name := Name;
                    SLCustomer.Phone := Phone;
                    SLCustomer.SlsperId := SlsperId;
                    SLCustomer.State := State;
                    SLCustomer.Status := Status;
                    SLCustomer.TaxID00 := CopyStr(TaxID00, 1, MaxStrLen(SLCustomer.TaxID00));
                    SLCustomer.Terms := Terms;
                    SLCustomer.Territory := CopyStr(Territory, 1, MaxStrLen(SLCustomer.Territory));
                    SLCustomer.Zip := Zip;
                    SLCustomer.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLCustomer.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLCustomer: Record "SL Customer";
}