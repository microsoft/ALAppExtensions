table 20184 "Action String Expression"
{
    Caption = 'Action String Expression';
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
        ScriptDataTypeMgmt.GetTokensFromStringExpression(Expression, TextTokens);

        ActionStringExprToken.Reset();
        ActionStringExprToken.SetRange("Case ID", "Case ID");
        ActionStringExprToken.SetRange("Script ID", "Script ID");
        ActionStringExprToken.SetRange("String Expr. ID", ID);
        if ActionStringExprToken.FindSet() then
            repeat
                if not TextTokens.Contains(ActionStringExprToken.Token) then
                    ActionStringExprToken.Delete(true);
            until ActionStringExprToken.Next() = 0;

        foreach Token in TextTokens do
            if not ActionStringExprToken.GET("Case ID", "Script ID", ID, Token) then begin
                ActionStringExprToken.Init();
                ActionStringExprToken."Case ID" := "Case ID";
                ActionStringExprToken."Script ID" := "Script ID";
                ActionStringExprToken."String Expr. ID" := ID;
                ActionStringExprToken.Token := Token;
                ActionStringExprToken.Insert();
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
        ActionStringExprToken.Reset();
        ActionStringExprToken.SetRange("Case ID", "Case ID");
        ActionStringExprToken.SetRange("Script ID", "Script ID");
        ActionStringExprToken.SetRange("String Expr. ID", ID);
        ActionStringExprToken.DeleteAll(true);
    end;

    var
        ActionStringExprToken: Record "Action String Expr. Token";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
}