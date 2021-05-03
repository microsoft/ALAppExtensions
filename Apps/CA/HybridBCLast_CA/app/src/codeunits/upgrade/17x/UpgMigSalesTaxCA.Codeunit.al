codeunit 10032 "Upg. Mig. Sales Tax CA"
{
    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 17.0 then
            exit;

        UpgradeSalesTaxDiffPositiveField();
    end;

    local procedure UpgradeSalesTaxDiffPositiveField()
    var
        SalesTaxAmountDifference: Record "Sales Tax Amount Difference";
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        ServiceLine: Record "Service Line";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        ServiceInvoiceLine: Record "Service Invoice Line";
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        Positive: Boolean;
    begin
        if SalesTaxAmountDifference.FindSet(true) then
            repeat
                Positive := true;
                case SalesTaxAmountDifference."Document Product Area" of
                    SalesTaxAmountDifference."Document Product Area"::Sales:
                        begin
                            SalesLine.SetRange("Document Type", SalesTaxAmountDifference."Document Type");
                            SalesLine.SetRange("Document No.", SalesTaxAmountDifference."Document No.");
                            SalesLine.SetRange("Tax Area Code", SalesTaxAmountDifference."Tax Area Code");
                            SalesLine.SetRange("Tax Group Code", SalesTaxAmountDifference."Tax Group Code");
                            SalesLine.CalcSums("Line Amount");
                            Positive := SalesLine."Line Amount" >= 0;
                        end;
                    SalesTaxAmountDifference."Document Product Area"::Purchase:
                        begin
                            PurchaseLine.SetRange("Document Type", SalesTaxAmountDifference."Document Type");
                            PurchaseLine.SetRange("Document No.", SalesTaxAmountDifference."Document No.");
                            PurchaseLine.SetRange("Tax Area Code", SalesTaxAmountDifference."Tax Area Code");
                            PurchaseLine.SetRange("Tax Group Code", SalesTaxAmountDifference."Tax Group Code");
                            PurchaseLine.CalcSums("Line Amount");
                            Positive := PurchaseLine."Line Amount" >= 0;
                        end;
                    SalesTaxAmountDifference."Document Product Area"::Service:
                        begin
                            ServiceLine.SetRange("Document Type", SalesTaxAmountDifference."Document Type");
                            ServiceLine.SetRange("Document No.", SalesTaxAmountDifference."Document No.");
                            ServiceLine.SetRange("Tax Area Code", SalesTaxAmountDifference."Tax Area Code");
                            ServiceLine.SetRange("Tax Group Code", SalesTaxAmountDifference."Tax Group Code");
                            ServiceLine.CalcSums("Line Amount");
                            Positive := ServiceLine."Line Amount" >= 0;
                        end;
                    SalesTaxAmountDifference."Document Product Area"::"Posted Sale":
                        case SalesTaxAmountDifference."Document Type" of
                            SalesTaxAmountDifference."Document Type"::Invoice:
                                begin
                                    SalesInvoiceLine.SetRange("Document No.", SalesTaxAmountDifference."Document No.");
                                    SalesInvoiceLine.SetRange("Tax Area Code", SalesTaxAmountDifference."Tax Area Code");
                                    SalesInvoiceLine.SetRange("Tax Group Code", SalesTaxAmountDifference."Tax Group Code");
                                    SalesInvoiceLine.CalcSums("Line Amount");
                                    Positive := SalesInvoiceLine."Line Amount" >= 0;
                                end;
                            SalesTaxAmountDifference."Document Type"::"Credit Memo":
                                begin
                                    SalesCrMemoLine.SetRange("Document No.", SalesTaxAmountDifference."Document No.");
                                    SalesCrMemoLine.SetRange("Tax Area Code", SalesTaxAmountDifference."Tax Area Code");
                                    SalesCrMemoLine.SetRange("Tax Group Code", SalesTaxAmountDifference."Tax Group Code");
                                    SalesCrMemoLine.CalcSums("Line Amount");
                                    Positive := SalesCrMemoLine."Line Amount" >= 0;
                                end;
                        end;
                    SalesTaxAmountDifference."Document Product Area"::"Posted Purchase":
                        case SalesTaxAmountDifference."Document Type" of
                            SalesTaxAmountDifference."Document Type"::Invoice:
                                begin
                                    PurchInvLine.SetRange("Document No.", SalesTaxAmountDifference."Document No.");
                                    PurchInvLine.SetRange("Tax Area Code", SalesTaxAmountDifference."Tax Area Code");
                                    PurchInvLine.SetRange("Tax Group Code", SalesTaxAmountDifference."Tax Group Code");
                                    PurchInvLine.CalcSums("Line Amount");
                                    Positive := PurchInvLine."Line Amount" >= 0;
                                end;
                            SalesTaxAmountDifference."Document Type"::"Credit Memo":
                                begin
                                    PurchCrMemoLine.SetRange("Document No.", SalesTaxAmountDifference."Document No.");
                                    PurchCrMemoLine.SetRange("Tax Area Code", SalesTaxAmountDifference."Tax Area Code");
                                    PurchCrMemoLine.SetRange("Tax Group Code", SalesTaxAmountDifference."Tax Group Code");
                                    PurchCrMemoLine.CalcSums("Line Amount");
                                    Positive := PurchCrMemoLine."Line Amount" >= 0;
                                end;
                        end;
                    SalesTaxAmountDifference."Document Product Area"::"Posted Service":
                        case SalesTaxAmountDifference."Document Type" of
                            SalesTaxAmountDifference."Document Type"::Invoice:
                                begin
                                    ServiceInvoiceLine.SetRange("Document No.", SalesTaxAmountDifference."Document No.");
                                    ServiceInvoiceLine.SetRange("Tax Area Code", SalesTaxAmountDifference."Tax Area Code");
                                    ServiceInvoiceLine.SetRange("Tax Group Code", SalesTaxAmountDifference."Tax Group Code");
                                    ServiceInvoiceLine.CalcSums("Line Amount");
                                    Positive := ServiceInvoiceLine."Line Amount" >= 0;
                                end;
                            SalesTaxAmountDifference."Document Type"::"Credit Memo":
                                begin
                                    ServiceCrMemoLine.SetRange("Document No.", SalesTaxAmountDifference."Document No.");
                                    ServiceCrMemoLine.SetRange("Tax Area Code", SalesTaxAmountDifference."Tax Area Code");
                                    ServiceCrMemoLine.SetRange("Tax Group Code", SalesTaxAmountDifference."Tax Group Code");
                                    ServiceCrMemoLine.CalcSums("Line Amount");
                                    Positive := ServiceCrMemoLine."Line Amount" >= 0;
                                end;
                        end;
                end;

                if Positive then begin
                    SalesTaxAmountDifference.Positive := Positive;
                    if SalesTaxAmountDifference.Modify() then;
                end;
            until SalesTaxAmountDifference.Next() = 0;
    end;
}