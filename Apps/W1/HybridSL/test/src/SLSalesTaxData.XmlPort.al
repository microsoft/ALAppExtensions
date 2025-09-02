// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147606 "SL SalesTax Data"
{
    Caption = 'SL SalesTax data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL SalesTax"; "SL SalesTax")
            {
                AutoSave = false;
                XmlName = 'SalesTax';

                textelement("TaxType")
                {
                }
                textelement("TaxID")
                {
                }
                textelement("Descr")
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
                    SLSalesTax: Record "SL SalesTax";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLSalesTax.TaxType := TaxType;
                    SLSalesTax.TaxId := TaxID;
                    SLSalesTax.Descr := Descr;
                    SLSalesTax.Insert(true);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLSalesTax.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLSalesTax: Record "SL SalesTax";
}
