namespace Microsoft.DataMigration.BC;

codeunit 4027 "W1 Transformation"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnTransformPerCompanyTableDataForVersion', '', false, false)]
    local procedure TransformPerCompanyTableData_15x(CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 15.0 then
            exit;

        OnAfterW1TransformationForVersion(CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnTransformPerCompanyTableDataForVersion', '', false, false)]
    local procedure TransformPerCompanyTableData_16x(CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 16.0 then
            exit;

        OnAfterW1TransformationForVersion(CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnTransformPerCompanyTableDataForVersion', '', false, false)]
    local procedure TransformPerCompanyTableData_17x(CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 17.0 then
            exit;

        OnAfterW1TransformationForVersion(CountryCode, TargetVersion);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnTransformPerCompanyTableDataForVersion', '', false, false)]
    local procedure TransformPerCompanyTableData_18x(CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 18.0 then
            exit;

        OnAfterW1TransformationForVersion(CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnTransformPerCompanyTableDataForVersion', '', false, false)]
    local procedure TransformPerCompanyTableData_19x(CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 19.0 then
            exit;

        OnAfterW1TransformationForVersion(CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnTransformPerCompanyTableDataForVersion', '', false, false)]
    local procedure TransformPerCompanyTableData_20x(CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 20.0 then
            exit;

        OnAfterW1TransformationForVersion(CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnTransformPerCompanyTableDataForVersion', '', false, false)]
    local procedure TransformPerCompanyTableData_21x(CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 21.0 then
            exit;

        OnAfterW1TransformationForVersion(CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnTransformNonCompanyTableDataForVersion', '', false, false)]
    local procedure TransformNonCompanyTableData_15x(CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 15.0 then
            exit;

        OnAfterW1NonCompanyTransformationForVersion(CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnTransformNonCompanyTableDataForVersion', '', false, false)]
    local procedure TransformNonCompanyTableData_16x(CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 16.0 then
            exit;

        OnAfterW1NonCompanyTransformationForVersion(CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnTransformNonCompanyTableDataForVersion', '', false, false)]
    local procedure TransformNonCompanyTableData_17x(CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 17.0 then
            exit;

        OnAfterW1NonCompanyTransformationForVersion(CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnTransformNonCompanyTableDataForVersion', '', false, false)]
    local procedure TransformNonCompanyTableData_18x(CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 18.0 then
            exit;

        OnAfterW1NonCompanyTransformationForVersion(CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnTransformNonCompanyTableDataForVersion', '', false, false)]
    local procedure TransformNonCompanyTableData_19x(CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 19.0 then
            exit;

        OnAfterW1NonCompanyTransformationForVersion(CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnTransformNonCompanyTableDataForVersion', '', false, false)]
    local procedure TransformNonCompanyTableData_20x(CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 20.0 then
            exit;

        OnAfterW1NonCompanyTransformationForVersion(CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnTransformNonCompanyTableDataForVersion', '', false, false)]
    local procedure TransformNonCompanyTableData_21x(CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 21.0 then
            exit;

        OnAfterW1NonCompanyTransformationForVersion(CountryCode, TargetVersion);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterW1TransformationForVersion(CountryCode: Text; TargetVersion: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterW1NonCompanyTransformationForVersion(CountryCode: Text; TargetVersion: Decimal)
    begin
    end;
}
