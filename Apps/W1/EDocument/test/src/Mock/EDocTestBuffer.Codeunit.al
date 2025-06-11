codeunit 139625 "E-Doc. Test Buffer"
{
    SingleInstance = true;

    var
        TempPurchHeader: Record "Purchase Header" temporary;
        TempPurchLine: Record "Purchase Line" temporary;
        EDocOrderNo: Code[20];

    procedure ClearTempVariables()
    begin
        TempPurchHeader.Reset();
        TempPurchHeader.DeleteAll();

        TempPurchLine.Reset();
        TempPurchLine.DeleteAll();
    end;

    procedure AddPurchaseDocToTemp(PurchHeader: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
    begin
        TempPurchHeader.Init();
        TempPurchHeader.TransferFields(PurchHeader);
        TempPurchHeader.Insert();

        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        if PurchLine.FindSet() then
            repeat
                TempPurchLine.Init();
                TempPurchLine.TransferFields(PurchLine);
                TempPurchLine.Insert();
            until PurchLine.Next() = 0;
    end;

    procedure SetEDocOrderNo(OrderNo: Code[20])
    begin
        EDocOrderNo := OrderNo;
    end;

    procedure GetPurchaseDocToTempVariables(var TmpPurchHeader2: Record "Purchase Header" temporary; var TmpPurchLine2: Record "Purchase Line" temporary)
    begin
        TmpPurchHeader2.Copy(TempPurchHeader, true);
        TmpPurchLine2.Copy(TempPurchLine, true);
    end;

    procedure GetEDocOrderNo(): Code[20]
    begin
        exit(EDocOrderNo);
    end;
}