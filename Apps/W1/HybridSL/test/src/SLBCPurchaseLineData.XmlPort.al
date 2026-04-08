// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Purchases.Document;

xmlport 147644 "SL BC Purchase Line Data"
{
    Caption = 'BC Purchase Line data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("Purchase Line"; "Purchase Line")
            {
                AutoSave = false;
                XmlName = 'PurchaseLine';
                UseTemporary = true;

                textelement(DocumentType)
                {
                }
                textelement(DocumentNo)
                {
                }
                textelement(LineNo)
                {
                }
                textelement(BuyFromVendorNo)
                {
                }
                textelement(Type)
                {
                }
                textelement("No.")
                {
                }
                textelement(LocationCode)
                {
                }
                textelement(Description)
                {
                }
                textelement(Quantity)
                {
                }
                textelement(DirectUnitCost)
                {
                }
                textelement(DimensionSetID)
                {
                }
                textelement(UnitofMeasureCode)
                {
                }
                textelement(PromisedReceiptDate)
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
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    Evaluate(TempPurchaseLine."Document Type", DocumentType);
                    TempPurchaseLine."Document No." := DocumentNo;
                    Evaluate(TempPurchaseLine."Line No.", LineNo);
                    TempPurchaseLine."Buy-from Vendor No." := BuyFromVendorNo;
                    if Type <> '' then
                        Evaluate(TempPurchaseLine.Type, Type);
                    TempPurchaseLine."No." := "No.";
                    TempPurchaseLine."Location Code" := LocationCode;
                    TempPurchaseLine.Description := Description;
                    Evaluate(TempPurchaseLine.Quantity, Quantity);
                    Evaluate(TempPurchaseLine."Direct Unit Cost", DirectUnitCost);
                    if DimensionSetID <> '' then
                        Evaluate(TempPurchaseLine."Dimension Set ID", DimensionSetID);
                    TempPurchaseLine."Unit of Measure Code" := UnitofMeasureCode;
                    if PromisedReceiptDate <> '' then
                        Evaluate(TempPurchaseLine."Promised Receipt Date", PromisedReceiptDate);
                    TempPurchaseLine.Insert(false);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        CaptionRow := true;
    end;

    procedure GetExpectedPurchaseLines(var NewTempPurchaseLine: Record "Purchase Line" temporary)
    begin
        if TempPurchaseLine.FindSet() then begin
            repeat
                NewTempPurchaseLine.Copy(TempPurchaseLine);
                NewTempPurchaseLine.Insert();
            until TempPurchaseLine.Next() = 0;
        end;
    end;

    var
        CaptionRow: Boolean;
        TempPurchaseLine: Record "Purchase Line" temporary;
}
