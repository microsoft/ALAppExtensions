codeunit 130457 "Test Profile Management"
{
    // Used to insert a profile into blank database
    // Web Client cannot load a blank company with no profiles


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000003, 'OnCompanyOpen', '', false, false)]
    local procedure TestProfileFunctions()
    var
        "Profile": Record "Profile";
    begin
        if Profile.FindFirst() then
          exit;

        Profile."Default Role Center" := true;
        Profile."Profile ID" := 'TEST ROLE CENTER';
        Profile."Role Center ID" := PAGE::"Test Role Center";
        Profile.Insert(true);
    end;
}

