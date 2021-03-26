codeunit 31246 "FA General Report CZF"
{
    procedure SetFATaxDeprGroup(var SetFixedAsset: Record "Fixed Asset"; DeprBookCode: Code[10])
    var
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        WindowDialog: Dialog;
        SortingTxt: Label 'Sorting Fixed Assets';
    begin
        WindowDialog.Open(SortingTxt);
        FixedAsset.LockTable();
        FixedAsset.Copy(SetFixedAsset);
        FixedAsset.SetCurrentKey("No.");
        FixedAsset.SetRange("Tax Deprec. Group Code CZF");
        if FixedAsset.FindSet() then
            repeat
                if FADepreciationBook.Get(FixedAsset."No.", DeprBookCode) then
                    if FixedAsset."Tax Deprec. Group Code CZF" <> FADepreciationBook."Tax Deprec. Group Code CZF" then begin
                        FixedAsset."Tax Deprec. Group Code CZF" := FADepreciationBook."Tax Deprec. Group Code CZF";
                        FixedAsset.Modify();
                    end;
            until FixedAsset.Next() = 0;
        Commit();
        WindowDialog.Close();
    end;
}
