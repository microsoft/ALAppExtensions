table 20247 "Tax Component Formula"
{
    DataClassification = EndUserIdentifiableInformation;

    fields
    {
        field(1; "Tax Type"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; ID; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(3; Expression; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Expression';
            trigger OnValidate();
            begin
                ValidateExpression();
            end;
        }
        field(4; "Component ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Component ID';
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
    begin
        TaxTypeObjectHelper.OnBeforeValidateIfUpdateIsAllowed(Rec."Tax Type");
    end;

    trigger OnModify()
    var
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
    begin
        TaxTypeObjectHelper.OnBeforeValidateIfUpdateIsAllowed(Rec."Tax Type");
    end;

    trigger OnDelete();
    var
        TaxComponentFormulaToken: Record "Tax Component Formula Token";
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
    begin
        TaxTypeObjectHelper.OnBeforeValidateIfUpdateIsAllowed(Rec."Tax Type");

        TaxComponentFormulaToken.Reset();
        TaxComponentFormulaToken.SetRange("Tax Type", "Tax Type");
        TaxComponentFormulaToken.SetRange("Formula Expr. ID", ID);
        TaxComponentFormulaToken.DeleteAll(true);
    end;

    local procedure ValidateExpression();
    var
        TaxComponentFormaulaToken: Record "Tax Component Formula Token";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TextTokens: List of [Text];
        Token: Text[250];
    begin
        ScriptDataTypeMgmt.GetTokensFromNumberExpression(Expression, TextTokens);

        TaxComponentFormaulaToken.Reset();
        TaxComponentFormaulaToken.SetRange("Tax Type", "Tax Type");
        TaxComponentFormaulaToken.SetRange("Formula Expr. ID", ID);
        if TaxComponentFormaulaToken.FindSet() then
            repeat
                if not TextTokens.Contains(TaxComponentFormaulaToken.Token) then
                    TaxComponentFormaulaToken.Delete(true);
            until TaxComponentFormaulaToken.Next() = 0;

        foreach Token in TextTokens do
            if not TaxComponentFormaulaToken.Get(ID, Token) then begin
                TaxComponentFormaulaToken.Init();
                TaxComponentFormaulaToken."Tax Type" := "Tax Type";
                TaxComponentFormaulaToken."Formula Expr. ID" := ID;
                TaxComponentFormaulaToken.Token := Token;
                TaxComponentFormaulaToken.Insert();
            end;
    end;
}