table 4761 "Manufacturing Demo Account"
{
    TableType = Temporary;

    fields
    {
        field(1; "Account Key"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Account Value"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Account Description"; text[50])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Account Key")
        {
            Clustered = true;
        }
    }

    var
        ManufacturingDemoAccounts: Codeunit "Manufacturing Demo Accounts";
        IsReturnKey: Boolean;

    procedure ReturnAccountKey(ReturnKey: boolean)
    begin
        IsReturnKey := ReturnKey;
    end;

    procedure FinishedGoods(): Code[20]
    begin
        if IsReturnKey then
            exit('992120');
        exit(ManufacturingDemoAccounts.GetAccount('992120'));
    end;

    procedure RawMaterials(): Code[20]
    begin
        if IsReturnKey then
            exit('992130');
        exit(ManufacturingDemoAccounts.GetAccount('992130'));
    end;


    procedure WIPAccountFinishedgoods(): Code[20]
    begin
        if IsReturnKey then
            exit('992140');
        exit(ManufacturingDemoAccounts.GetAccount('992140'));
    end;

    procedure DirectCostAppliedCap(): Code[20]
    begin
        if IsReturnKey then
            exit('997791');
        exit(ManufacturingDemoAccounts.GetAccount('997791'));
    end;

    procedure OverheadAppliedCap(): Code[20]
    begin
        if IsReturnKey then
            exit('997792');
        exit(ManufacturingDemoAccounts.GetAccount('997792'));
    end;

    procedure PurchaseVarianceCap(): Code[20]
    begin
        if IsReturnKey then
            exit('997793');
        exit(ManufacturingDemoAccounts.GetAccount('997793'));
    end;

    procedure MaterialVariance(): Code[20]
    begin
        if IsReturnKey then
            exit('997890');
        exit(ManufacturingDemoAccounts.GetAccount('997890'));
    end;

    procedure CapacityVariance(): Code[20]
    begin
        if IsReturnKey then
            exit('997891');
        exit(ManufacturingDemoAccounts.GetAccount('997891'));
    end;

    procedure SubcontractedVariance(): Code[20]
    begin
        if IsReturnKey then
            exit('997892');
        exit(ManufacturingDemoAccounts.GetAccount('997892'));
    end;

    procedure CapOverheadVariance(): Code[20]
    begin
        if IsReturnKey then
            exit('997893');
        exit(ManufacturingDemoAccounts.GetAccount('997893'));
    end;

    procedure MfgOverheadVariance(): Code[20]
    begin
        if IsReturnKey then
            exit('997894');
        exit(ManufacturingDemoAccounts.GetAccount('997894'));
    end;

    procedure DirectCostAppliedRetail(): Code[20]
    begin
        if IsReturnKey then
            exit('997192');
        exit(ManufacturingDemoAccounts.GetAccount('997192'));
    end;

    procedure OverheadAppliedRetail(): Code[20]
    begin
        if IsReturnKey then
            exit('997192');
        exit(ManufacturingDemoAccounts.GetAccount('997192'));
    end;

    procedure PurchaseVarianceRetail(): Code[20]
    begin
        if IsReturnKey then
            exit('997193');
        exit(ManufacturingDemoAccounts.GetAccount('997193'));
    end;

    procedure DirectCostAppliedRawMat(): Code[20]
    begin
        if IsReturnKey then
            exit('997291');
        exit(ManufacturingDemoAccounts.GetAccount('997291'));
    end;

    procedure OverheadAppliedRawMat(): Code[20]
    begin
        if IsReturnKey then
            exit('997292');
        exit(ManufacturingDemoAccounts.GetAccount('997292'));
    end;

    procedure PurchaseVarianceRawMat(): Code[20]
    begin
        if IsReturnKey then
            exit('997293');
        exit(ManufacturingDemoAccounts.GetAccount('997293'));
    end;

    procedure PurchRawMatDom(): Code[20]
    begin
        if IsReturnKey then
            exit('997210');
        exit(ManufacturingDemoAccounts.GetAccount('997210'));
    end;

    procedure InventoryAdjRawMat(): Code[20]
    begin
        if IsReturnKey then
            exit('997270');
        exit(ManufacturingDemoAccounts.GetAccount('997270'));
    end;

    procedure InventoryAdjRetail(): Code[20]
    begin
        if IsReturnKey then
            exit('997170');
        exit(ManufacturingDemoAccounts.GetAccount('997170'));
    end;
}