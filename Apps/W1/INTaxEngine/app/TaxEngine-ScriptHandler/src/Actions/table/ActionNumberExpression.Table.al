table 20179 "Action Number Expression"
{
    Caption = 'Action Number Expression';
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; "Case ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Case ID';
        }
        field(2; "Script ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Script ID';
        }
        field(3; ID; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }
        field(4; Expression; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Expression';
            trigger OnValidate();
            begin
                ValidateExpression();
            end;
        }
        field(5; "Variable ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Variable ID';
            TableRelation = "Script Variable".ID where("Script ID" = field("Script ID"));
        }
    }

    keys
    {
        key(K0; "Case ID", "Script ID", ID)
        {
            Clustered = True;
        }
    }
    local procedure ValidateExpression();
    var
        TextTokens: List of [Text];
        Token: Text[250];
    begin
        ScriptDataTypeMgmt.GetTokensFromNumberExpression(Expression, TextTokens);

        ActionNumberExprToken.Reset();
        ActionNumberExprToken.SetRange("Case ID", "Case ID");
        ActionNumberExprToken.SetRange("Script ID", "Script ID");
        ActionNumberExprToken.SetRange("Numeric Expr. ID", ID);
        if ActionNumberExprToken.FindSet() then
            repeat
                if not TextTokens.Contains(ActionNumberExprToken.Token) then
                    ActionNumberExprToken.Delete(true);
            until ActionNumberExprToken.Next() = 0;

        foreach Token in TextTokens do
            if not ActionNumberExprToken.GET("Case ID", "Script ID", ID, Token) then begin
                ActionNumberExprToken.Init();
                ActionNumberExprToken."Case ID" := "Case ID";
                ActionNumberExprToken."Script ID" := "Script ID";
                ActionNumberExprToken."Numeric Expr. ID" := ID;
                ActionNumberExprToken.Token := Token;
                ActionNumberExprToken.Insert();
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
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
        ActionNumberExprToken.Reset();
        ActionNumberExprToken.SetRange("Case ID", "Case ID");
        ActionNumberExprToken.SetRange("Script ID", "Script ID");
        ActionNumberExprToken.SetRange("Numeric Expr. ID", ID);
        ActionNumberExprToken.DeleteAll(true);
    end;

    var
        ActionNumberExprToken: Record "Action Number Expr. Token";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
}