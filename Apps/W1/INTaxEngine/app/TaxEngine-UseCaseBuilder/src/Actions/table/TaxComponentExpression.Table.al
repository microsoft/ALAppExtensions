table 20285 "Tax Component Expression"
{
    Caption = 'Tax Component Expression';
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; "Case ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Case ID';
            TableRelation = "Tax Use Case";
        }
        field(2; ID; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
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
        key(K0; "Case ID", ID)
        {
            Clustered = True;
        }
    }
    local procedure ValidateExpression();
    var
        UseCase: Record "Tax Use Case";
        TextTokens: List of [Text];
        Token: Text[250];
    begin
        ScriptDataTypeMgmt.GetTokensFromNumberExpression(Expression, TextTokens);

        UseCase.Get("Case ID");
        TaxComponentExprToken.Reset();
        TaxComponentExprToken.SetRange("Case ID", "Case ID");
        TaxComponentExprToken.SetRange("Script ID", UseCase."Computation Script ID");
        TaxComponentExprToken.SetRange("Component Expr. ID", ID);
        if TaxComponentExprToken.FindSet() then
            repeat
                if not TextTokens.Contains(TaxComponentExprToken.Token) then
                    TaxComponentExprToken.Delete(true);
            until TaxComponentExprToken.Next() = 0;

        foreach Token in TextTokens do
            if not TaxComponentExprToken.GET("Case ID", UseCase."Computation Script ID", ID, Token) then begin
                TaxComponentExprToken.Init();
                TaxComponentExprToken."Case ID" := "Case ID";
                TaxComponentExprToken."Script ID" := UseCase."Computation Script ID";
                TaxComponentExprToken."Component Expr. ID" := ID;
                TaxComponentExprToken.Token := Token;
                TaxComponentExprToken.Insert();
            end;
    end;

    trigger OnInsert()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
    end;

    trigger OnModify()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
    end;

    trigger OnDelete();
    var
        UseCase: Record "Tax Use Case";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");

        UseCase.Get("Case ID");
        TaxComponentExprToken.Reset();
        TaxComponentExprToken.SetRange("Case ID", "Case ID");
        TaxComponentExprToken.SetRange("Script ID", UseCase."Computation Script ID");
        TaxComponentExprToken.SetRange("Component Expr. ID", ID);
        TaxComponentExprToken.DeleteAll(true);
    end;

    var
        TaxComponentExprToken: Record "Tax Component Expr. Token";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
}