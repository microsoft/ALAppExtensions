codeunit 4057 "Upg Mig User Callouts"
{
    trigger OnRun()
    begin
        // This code is based on standard app upgrade logic.
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnUpgradeNonCompanyDataForVersion', '', false, false)]
    local procedure OnUpgradeNonCompanyUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 18.0 then
            exit;

        PopulateUserCallouts();
    end;

    local procedure PopulateUserCallouts()
    var
        User: Record User;
        UserCallouts: Record "User Callouts";
    begin
        if User.FindSet() then
            repeat
                if not UserCallouts.Get(User."User Security ID") then begin
                    UserCallouts."User Security ID" := User."User Security ID";
                    UserCallouts.Enabled := false;
                    UserCallouts.Insert();
                end;
            until (User.Next() = 0);
    end;
}