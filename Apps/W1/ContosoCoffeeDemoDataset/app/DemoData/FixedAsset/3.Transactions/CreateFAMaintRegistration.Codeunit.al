codeunit 5123 "Create FA Maint. Registration"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoUtilities: Codeunit "Contoso Utilities";
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
        CreateFixedAsset: Codeunit "Create Fixed Asset";
    begin
        ContosoFixedAsset.InsertFAMaintenanceRegistration(CreateFixedAsset.FA000010(), ContosoUtilities.AdjustDate(19030131D), CommentMileage3000ServiceLbl, ServiceAgent1());
        ContosoFixedAsset.InsertFAMaintenanceRegistration(CreateFixedAsset.FA000020(), ContosoUtilities.AdjustDate(19030515D), CommentMileage3000ServiceLbl, ServiceAgent2());
        ContosoFixedAsset.InsertFAMaintenanceRegistration(CreateFixedAsset.FA000030(), ContosoUtilities.AdjustDate(19030618D), CommentMileage3000ServiceLbl, ServiceAgent3());
        ContosoFixedAsset.InsertFAMaintenanceRegistration(CreateFixedAsset.FA000050(), ContosoUtilities.AdjustDate(19030114D), CommentMileage3000ServiceLbl, ServiceAgent4());
        ContosoFixedAsset.InsertFAMaintenanceRegistration(CreateFixedAsset.FA000060(), ContosoUtilities.AdjustDate(19030218D), CommentMileage3000ServiceLbl, ServiceAgent4());
        ContosoFixedAsset.InsertFAMaintenanceRegistration(CreateFixedAsset.FA000070(), ContosoUtilities.AdjustDate(19030415D), CommentMileage3000ServiceLbl, ServiceAgent4());
        ContosoFixedAsset.InsertFAMaintenanceRegistration(CreateFixedAsset.FA000080(), ContosoUtilities.AdjustDate(19030420D), Comment100hourServiceLbl, ServiceAgent5());
        ContosoFixedAsset.InsertFAMaintenanceRegistration(CreateFixedAsset.FA000090(), ContosoUtilities.AdjustDate(19030202D), CommentMileage3000ServiceLbl, ServiceAgent6());
    end;

    procedure ServiceAgent1(): Code[30]
    begin
        exit(ServiceAgent1Lbl);
    end;

    procedure ServiceAgent2(): Code[30]
    begin
        exit(ServiceAgent2Lbl);
    end;

    procedure ServiceAgent3(): Code[30]
    begin
        exit(ServiceAgent3Lbl);
    end;

    procedure ServiceAgent4(): Code[30]
    begin
        exit(ServiceAgent4Lbl);
    end;

    procedure ServiceAgent5(): Code[30]
    begin
        exit(ServiceAgent5Lbl);
    end;

    procedure ServiceAgent6(): Code[30]
    begin
        exit(ServiceAgent6Lbl);
    end;

    var
        CommentMileage3000ServiceLbl: Label 'Mileage 3000 service', MaxLength = 50;
        Comment100hourServiceLbl: Label '100 hours service', MaxLength = 50;
        ServiceAgent1Lbl: Label 'Gregory J. Erickson', MaxLength = 30;
        ServiceAgent2Lbl: Label 'Larry Zhang', MaxLength = 30;
        ServiceAgent3Lbl: Label 'Josh Barnhill', MaxLength = 30;
        ServiceAgent4Lbl: Label 'Kelly Focht', MaxLength = 30;
        ServiceAgent5Lbl: Label 'Taylor Maxwell', MaxLength = 30;
        ServiceAgent6Lbl: Label 'John Campbell III', MaxLength = 30;
}