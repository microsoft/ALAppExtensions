codeunit 139625 "E-Doc. Test Buffer"
{
    SingleInstance = true;

    var
        TmpPurchHeader: Record "Purchase Header" temporary;
        TmpPurchLine: Record "Purchase Line" temporary;
        EDocOrderNo: Code[20];

    procedure ClearTempVariables()
    begin
        TmpPurchHeader.Reset();
        TmpPurchHeader.DeleteAll();

        TmpPurchLine.Reset();
        TmpPurchLine.DeleteAll();
    end;

    procedure AddPurchaseDocToTemp(PurchHeader: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
    begin
        TmpPurchHeader.Init();
        TmpPurchHeader.TransferFields(PurchHeader);
        TmpPurchHeader.Insert();

        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        if PurchLine.FindSet() then
            repeat
                TmpPurchLine.Init();
                TmpPurchLine.TransferFields(PurchLine);
                TmpPurchLine.Insert();
            until PurchLine.Next() = 0;
    end;

    procedure SetEDocOrderNo(OrderNo: Code[20])
    begin
        EDocOrderNo := OrderNo;
    end;

    procedure GetPurchaseDocToTempVariables(var TmpPurchHeader2: Record "Purchase Header" temporary; var TmpPurchLine2: Record "Purchase Line" temporary)
    begin
        TmpPurchHeader2.Copy(TmpPurchHeader, true);
        TmpPurchLine2.Copy(TmpPurchLine, true);
    end;

    procedure GetEDocOrderNo(): Code[20]
    begin
        exit(EDocOrderNo);
    end;
}