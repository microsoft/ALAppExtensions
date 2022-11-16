codeunit 148116 "Test Initialize Handler CZF"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Test Initialize", 'OnBeforeTestSuiteInitialize', '', false, false)]
    local procedure UpdateRecordsOnBeforeTestSuiteInitialize(CallerCodeunitID: Integer)
    begin
        case CallerCodeunitID of
            134027: // "ERM Invoice Discount And VAT"
                DeleteAllFAExtPostingGroup();
            134451: // "ERM Fixed Assets"
                UpdateFASetup();
      end;
    end;

    local procedure DeleteAllFAExtPostingGroup()
    var
        FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF";
    begin
        FAExtendedPostingGroupCZF.DeleteAll();
    end;

    local procedure UpdateFASetup()
        var
        FASetup: Record "FA Setup";
    begin
        FASetup.Get();
        FASetup.Validate("FA Acquisition As Custom 2 CZF", false);
        FASetup.Modify(true);
    end;
}