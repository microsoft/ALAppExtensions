codeunit 130303 "XS Library - Random"
{
    var
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";

    procedure CreateGUID() CreatedGUID: Text
    begin

        CreatedGUID := AddPartToGUID(8, true) +
                       AddPartToGUID(4, false) +
                       AddPartToGUID(4, false) +
                       AddPartToGUID(4, false) +
                       AddPartToGUID(12, false);
    end;

    local procedure AddPartToGUID(StringLength: Integer; First: Boolean) GUIDPart: Text
    begin
        if not First then
            GUIDPart := '-';
        GUIDPart := GUIDPart + LibraryRandom.RandText(StringLength);
    end;

    procedure CreateRandomUTCDate() CreatedUTCDate: Text
    begin
        CreatedUTCDate := '\/Date(' + Format(LibraryRandom.RandInt(13)) + ')\/';
    end;

    procedure CreateRandomEmail() CreatedEmail: Text
    begin
        CreatedEmail := LibraryUtility.GenerateRandomEmail();
    end;
}