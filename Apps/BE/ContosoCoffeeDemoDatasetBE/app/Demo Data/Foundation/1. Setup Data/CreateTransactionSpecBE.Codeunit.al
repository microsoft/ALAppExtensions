codeunit 11393 "Create Transaction Spec. BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertTransactionSpeceficationData(CFR(), CostandFreightLbl);
        InsertTransactionSpeceficationData(CIF(), CostInsuranceAndFreightLbl);
        InsertTransactionSpeceficationData(CIP(), CarriageAndInsurancePaidLbl);
        InsertTransactionSpeceficationData(CPT(), CarriagePaidtoLbl);
        InsertTransactionSpeceficationData(DAF(), DeliveredAtFrontierLbl);
        InsertTransactionSpeceficationData(DDP(), DeliveredDutyPaidLbl);
        InsertTransactionSpeceficationData(DDU(), DeliveredDutyUnpaidLbl);
        InsertTransactionSpeceficationData(DEQ(), DeliveredExQuayLbl);
        InsertTransactionSpeceficationData(DES(), DeliveredExShipLbl);
        InsertTransactionSpeceficationData(EXW(), ExWarehouseLbl);
        InsertTransactionSpeceficationData(FAS(), FreeAlongsideShipLbl);
        InsertTransactionSpeceficationData(FCA(), FreeCarrierLbl);
        InsertTransactionSpeceficationData(FOB(), FreeonBoardLbl);
        InsertTransactionSpeceficationData(XXX(), OtherShipmentConditionLbl);
    end;

    local procedure InsertTransactionSpeceficationData(TransactionCode: COde[10]; TransactionText: Text[50])
    var
        TransactionData: Record "Transaction Specification";
    begin
        TransactionData.Init();
        TransactionData.Validate(Code, TransactionCode);
        TransactionData.Validate(Text, TransactionText);
        TransactionData.Insert(true);
    end;

    procedure CFR(): Code[10]
    begin
        exit(CFRTok);
    end;

    procedure CIF(): Code[10]
    begin
        exit(CIFTok);
    end;

    procedure CIP(): Code[10]
    begin
        exit(CIPTok);
    end;

    procedure CPT(): Code[10]
    begin
        exit(CPTTok);
    end;

    procedure DAF(): Code[10]
    begin
        exit(DAFTok);
    end;

    procedure DDP(): Code[10]
    begin
        exit(DDPTok);
    end;

    procedure DDU(): Code[10]
    begin
        exit(DDUTok);
    end;

    procedure DEQ(): Code[10]
    begin
        exit(DEQTok);
    end;

    procedure DES(): Code[10]
    begin
        exit(DESTok);
    end;

    procedure EXW(): Code[10]
    begin
        exit(EXWTok);
    end;

    procedure FAS(): Code[10]
    begin
        exit(FASTok);
    end;

    procedure FCA(): Code[10]
    begin
        exit(FCATok);
    end;

    procedure FOB(): Code[10]
    begin
        exit(FOBTok);
    end;

    procedure XXX(): Code[10]
    begin
        exit(XXXTok);
    end;

    var
        CFRTok: Label 'CFR', Locked = true, MaxLength = 10;
        CIFTok: Label 'CIF', Locked = true, MaxLength = 10;
        CIPTok: Label 'CIP', Locked = true, MaxLength = 10;
        CPTTok: Label 'CPT', Locked = true, MaxLength = 10;
        DAFTok: Label 'DAF', Locked = true, MaxLength = 10;
        DDPTok: Label 'DDP', Locked = true, MaxLength = 10;
        DDUTok: Label 'DDU', Locked = true, MaxLength = 10;
        DEQTok: Label 'DEQ', Locked = true, MaxLength = 10;
        DESTok: Label 'DES', Locked = true, MaxLength = 10;
        EXWTok: Label 'EXW', Locked = true, MaxLength = 10;
        FASTok: Label 'FAS', Locked = true, MaxLength = 10;
        FCATok: Label 'FCA', Locked = true, MaxLength = 10;
        FOBTok: Label 'FOB', Locked = true, MaxLength = 10;
        XXXTok: Label 'XXX', Locked = true, MaxLength = 10;
        CostandFreightLbl: Label 'Cost and Freight', MaxLength = 50;
        CostInsuranceAndFreightLbl: Label 'Cost Insurance and Freight', MaxLength = 50;
        CarriageAndInsurancePaidLbl: Label 'Carriage and Insurance Paid', MaxLength = 50;
        CarriagePaidtoLbl: Label 'Carriage Paid to', MaxLength = 50;
        DeliveredAtFrontierLbl: Label 'Delivered at Frontier', MaxLength = 50;
        DeliveredDutyPaidLbl: Label 'Delivered Duty Paid', MaxLength = 50;
        DeliveredDutyUnpaidLbl: Label 'Delivered Duty Unpaid', MaxLength = 50;
        DeliveredExQuayLbl: Label 'Delivered ex Quay', MaxLength = 50;
        DeliveredExShipLbl: Label 'Delivered ex Ship', MaxLength = 50;
        ExWarehouseLbl: Label 'Ex Warehouse', MaxLength = 50;
        FreeAlongsideShipLbl: Label 'Free Alongside Ship', MaxLength = 50;
        FreeCarrierLbl: Label 'Free Carrier', MaxLength = 50;
        FreeonBoardLbl: Label 'Free on Board', MaxLength = 50;
        OtherShipmentConditionLbl: Label 'Other Shipment Condition', MaxLength = 50;
}