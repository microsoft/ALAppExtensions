// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4500 "Current User Connector" implements "Email Connector"
{
    Access = Internal;
    Permissions = tabledata "Email - Outlook Account" = rimd;

    var
        ConnectorDescriptionTxt: Label 'Users send emails from their sign-in account.';
        CurrentUserConnectorBase64LogoTxt: Label 'iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAQdUlEQVR4Ae2dBXAbyfLGfcwY/MMLHDPk/JiZIY+ZGXzMzMyMoWNm5nNAscPJOVEcZkNODimOZc/rX6XrdLCjtWJp1VJ2qr6qxNqd+Xq6B3amp6eqYtLxo0E/wScEPxIcI7hW8JggIZgtSAlcCFL6bELfvVbz+pHmTRlVcSqtosGOggGCLwlOFowS1Aoas4ouKFKad62WdbKWPUC5VIHip1jp1YJ/CUYIGgRrBBmBixgZLbtBucCpuvDGECt+J8HBghrBC4IFgg0CZwxwWqAca5TzTptmCLHStxD0EgwV3KkV2ylwZYJO5XynytBLZQoRPlb8loLBgr8J3hS0CVyZo01l+ZvKtmVsCMEtfoDgeEG9oEPgKgzIVK8yDoh7BBFe0V/HzEmCdoGrcLSrrDUqexXYHBW/s35bvyZIC9xmhrTK/iOtiyqwuYzz1YJh2e/1zRoprYtqrZuKbvV7aNeXFHTFyn8XXVonNVpHVaDSlH+Y4MGc3X2MtNbRYRVhBCrEdoKfCSbFCu42JmmdUXdl3ep7Cc4WtMZKzRutWne9yq43UMKDBXcL1sfK3GRQd3drXZZVyx8ieLkgy7cxOrUuh2jdmv/E+5KgPlZcwVGvdUsdm2353xAkY2UVDUmt4ypgbS3/67HyIzOCr2ud21B+yVp+3BNQ9yXv9r9UFso/TnBs7UYcI+D/WfC37O/HlY0RfEl1UDIDOEpQZ1fpoNZtKf/ufVbCHXjpRPeZG6a5r906w/3xgUb394fnAP7N3/iNZ3iWd3jXujHUqQ5K0vIH6+eJswZa8TYnjnEDL6h3Pxs1y1375lL3wqx3XMOKdW7V+ozr6nIfSvyN33iGZ3mHd8mDvMjToqyqg8HR9QTZFb67rW3o0GJ3OnWs+9LN093Vbyxxyaa0W9MuCnf5J97hXfIgL/Ikb8owuJF0t+oksrX9swXtlrr67U4a475yywx3z4Rm17R6gytwIk/ypgzKsjY0tKtO0E3Ru/6fCVosKX/QhfXu8teWuBUovriJMiiLMq0ZQYvqBh0VdUvXzK4eY/M3b3/bvTW3jTE8skRZlEnZcDC2i1iEreSsM8cDlrr8fz4yxy1pa89beR2dXa490+XWd4CN/+ZveRoRZcPB2pDwgOqq4Is9NYK0BeXveto4d96Li1xbOuPCE5O5Tjdj+Tr34OQWd/qzC9wv7066T1431VVfPQXwb/nbLHfmcwvco1NbHc/yTjcSHOACJytGkFZdobOCdf3VgqQF5e986jh3wcuLXHpDuIKa13Q4lI5y975ogttKu2tdFHo/VHk8w7O8w7vkEZLgAie4WTGCJDrr+VCQ9d4dZqF721qU85/H5rq29ZnQFn//pGb3xZum0zJVwfmvGvIuedw7sdmtDikTTnDb2s6cYJjqrset/0eClIXW//27GnLO9LsEfLf/6cFGt/vpPsXnv5K4ixjCHx+YTd6U4Utwg6OVXiCF7ja9F8ge2njVgvJZop24eI3LlV5tTLmPXzvFbYECQAHLJ0/ypowcCY5wtWIEr6oOezDxM+DSteMpY92tY5c7X5IJvHtsWqvb/5KJRV2pI2/KoCzK9CS4wtmKS1n+E0I1gAGCiRaWd793V0POydhLyXeYuPFsJHwoizJ9Ca5wNrJsPFF1mffYf7ygvdRd/55nJtwzDSudL01dupZPuUgrm7Iok7I9Cc5wtzAUtKNL1WleHr31Fsb+ocMb3FrPNzmbNb+6J1mSlkaZlA2HoARnuBuZC9SrTrvd+v9u4Yj2DjKO3iefc750Z2KF7NCNKxk/yoaDL8EdGYwcTf+76rZbW71vWtjTP/KqyW5OS9oFpbmt62VWPpXnSsoRDnAJSHBHBiu+BOi0V3cMYKiV7368dXyT7RtHL3NbnlDySoUDXLzrEshgaF0A3eZU/g4a18ZZ6P7vmdjkHftx4TIwy4YDXHxzAWSwMgyAO1XHXgM4RLDAQuvvf85497a4ZwWlcfNXOX7nOStc4RSUkMEKV9XtIbkMoEbQaaFSP3X9VPmeDl72veL1JZbW3B1c4BSQkAFZrBhAp+o4UPk7Cl6w4tv3m3uTgZ9/GzJd7g/3z8aN24oBwAVOcAv6HEQWS76EL6iuP2QAHxXMt+LVe/yT83DSCNpwwS/PlJcuXOAUtFGFDMhiiO+8rCu5Kl/xL0HGSoVeKPvrQamxJe0Ov3KyKe9cuMAJbkEJWdQADK4JZLv/4ZZa1M1jgj+tpi9b6wZdYMshEy5wgltQQhZj5wqGq87ft/HTUA4GME0qeaBBA4DTtPIxgIbsBlH2fN8aSwZw1RvBs+qZK9axJWvOAOAEt4CELNYMYI3q/F0DOFmQsWQAp4nzZmeAm+7iVLuc4ZtqbhIIJ7h9ICEDslgzgIzq/F0DGGXtbB9LqOs7PvwZiG/eT0bMtGYAcAr0G0QGZDHFF6BzNYB+glprp3pZXl25LtgJ5NRn5psbAuAUlJABWUzxBegc3es9OI3WDACvm6AulYRL1m6njzOzFAwXOAUkZEAWiwbQiO4xgB9bjMuPJ+5LyZQLSstWbXCHXD7JzGYQXOAUkJABWWzeY4Du9UYsZw1ss579/EIXlDIysTqViZURrnCBU0BCBt22NoljMIBrrQZ5+KqMne+s6/C6X++jjqAlbP1w8Lqrwx0ZDAeXuBYDeMxmeBfCuox3r8wOHgZYYz/l6fluyxJypGw4wCUowR0ZDIeZeQwDSFiO8cNxK3bZcrpclcgpNJfLGpzhblj5IIEBzLZsAB85v96NX7ja+dLDU1tc37NpZdHyokzK9iQ4w922AaD7cri1g5bEGX7fUEDEDk7iRFHZlEFZlOnp+uEK5/K4raQc4vv1O2e895OQtLo94855YSFu2jxfVC6UQVmU6UlwhbNyMQ7zBLOOl3xr5zwSzhn9XmcmeL4oHMibMijLk+BYcIfV2AA0HtBJMuNelyMwBOvunOU/mEWiQp0Q1nzIk7wpw5PgBsdixA2KDQAlcOb/jsTynCdz+WnykjXE7nF9zhqvR8VrN6nF8y55kBd55igWTnCDI1xjAyjSUCAz6zr38JQWVt5Cw7YQyevPDza6vWSxhtU4FKPhX4Ohv/Es7/AueZBXrgQXOMFNjS02gKJ635xfzydYiBFkh4UpS9fQOlGoGyKnegeI9w6TtN3PSAD+zd/cEfJd/3vx7uVZ3uHdsAQHuMBJW35sAFEsE+OCNaJuhW+RyLs4Q1QvFm/GykGOJ6a3Av7N3/jNteeXHxzgosu9sQFEu1Qss/Kz5ZNsOe7YESfKpGw4aMsvT5Tz9a2Mt1sdvzGGwIzla11UibIok7LDx3z7C0Gzy1X5O52yMTL4sPEr3Mq1HS6iRFmUSdlwKF8j0KXgRLl1/Xxnc7nD8Lom18T5wdIkyoYDXOBUjkNBwuZ2cEhk8PNfWqQxgm0kuMDJH0Hc9nbwteXS6llifb2xzWVYdckj8Tgeu0zc5q9c7xKyU8de/asK/s3f+I1neDbPIuAENziWU29wrbqE2V8BPOGp+Xm1epYIFohCH5fPvAukdf505Cz27zmrjxMnfnrvA3/jN57hWd7hXfIgrzx6A7iWy4rgMVmnUKMTvf87t87dPm65W7uhs1tKJ0bfsw0r3V8fakSZLhsrGJBn+Lo/z2qsYPIgL/Ik7+4YA1zhDHfLE0R1ClW3cIvK3/fiCe4hXfbtzsz87glNdMHZbeFCxArWPMiTvCmDssISnOGODCaNQN3CjR4MqXUHSbzdV5KpsLGYrVli/ON8SVde9FCxlEFZlEnZIXMPZEAW3jV7MASMMtXtn1fHEm3orV6zmtIcuypMZPA8ewXKpGw4hNgosiCTNSMYZe9wKKFhZXNmZH0Ts+rQ4NBDrp7sttD3SsGVsuEQEjwaWZAJ2XjPzOFQU8fDqZgdTh7L9SuhThfX1y51/c4eb+VkEFzgFOasgmzIiKwmjoebChBBpRB7N5XO5FT+xa8sDriaxcZVNnDLYQTIprGNbQSIMBMihgo59IpJRN8OU75O9GyuV8AtxAiQEVl53kKIGANBorT1sLniS+zRX/oqLd9A9xkqy1i45vQrQNYS9mIZ1TU6NxAm7riNwRW4uNk34RtV36TevuWxXwFXOHsmhsiKzKWaw8xXXZc+UCSV9b+yWvZaYyrnCZsD/DGBzBoBnOHuSciM7DxbqkCRJkLF4nFLd+m9sHnocFpKeXoswR0ZPMMaspckVKyNYNF6+hd/PF+6oXYZ17LyfFkC7sjgSciup4ftBIuOLFw8498v7p7lvQ4m2Zw2MFsuzNcNsgQkZKcOqAsD4eKjuzBCN1fGugcmN+eMAKKRNcoZyJAzggh1sFM0XzcpdGvhyhi9amWKd3+fGPsHZDdQyhnIgCzI5PMfoC6ok6iujLFxadSxT8xzvnSlRNbc6gQd+ysAyIJMnkRdGLg0Krpr47hChR0y73LpZ2+YVhmtX4EsyIRsnt1C6iSKa+MMXBx53MZzd3Nb0964On2jnRlHE1HEH++IuqBOeM7AxZFFvjqW1jB0WIO3NRB8oeyV7zECZPP0etQJdWPg6tgiXx7NZOd0mRV3eSrih8PtxAEusNzIFmT41AV1wjNGLo8u4vXx2540hs0Q320glq5eL8oV+Mjo2SCiboxcH68GoPiRIFXI1b/nZgbfvD1GVsa218lQJQLZkDEgUSeFXhVMobvwsT/cCHYWDCvU+M85/MSC1Z5FkZbsdXAVCGRDxqBEnVA3BZwH3IXu8la+pxeoFiQLMQ4efNkkN89z1+5lry3W1b/KBLIhY1CiTqibAs0DZgqO7FHr90wI0z01ACJrcwQrKJ0lgZW34LkKBbIhY1CiTqibAhhA2jPx67ER7CF4oKcGcIRcr8byJ0vjrI8rCLpICBcdAysTyIaMyIrMCuqCOqFuCmEAD6iu0FxBDQAcJpjUUweQY56YK+fn5r0PXK5IKDaeq2AgI7J+SH7qpAAOIpPQUWG6fr8R/EzQYq5yY7Sgm4Iq32ME2wnOFrSbET5Gu+pku8Ir379lfLegq+TCx+hCF+FbvYUfCgYLXo4VUHK8rLqoApElLfAoQV3JhI9Rhw4iU7ynJ/iSIBm58DGS1H20Ld+/SPSN2AgiV/43/Is9pTGCr8dGEJnyv25A+YHDQdwTRNPyq4CppKS2FHypKP6EMeq1brc0pXxPTzBE8HJBjpnF6NS6HGKv5Yd7Ft/dI5eyGNTd3eEevXZ7gl66RNmat/AxWrXuetlv+eF7Bz/LaxcxxiSts+3KU/H+reQHczqVxEhTR/4t3fI3gj3UWyX5oY2keKI3U+tmj8pRvv9TsVodTVNVsfJT6sB5pKlPvAh6g53Vbfm1zXRYSKvsP6Iu/K2+8g2hv3Z9kzYTJ5N2lbUG2Q0o3sxewgDB8bri1VGBikemepVxgIG1fLPzg8GCv2lAg7YKUHybyoJMg7s/zsc9Qi/BUI1rs6DMlpU7lfOdKkOvTW/xsTHsJDhY8A/B81qxG4wu287XOHw1ynmnWOmFnTDuqJ+Q/xKM0KDHa0oU6j6jZTcol78LjoJjPLGLzhgG6BbpyXoBQq2gsUjrCynNu1bLOlnLHmBH6bFh9NM7kH6kt6Fdq/ciJgSzu2kYKX02oe9eq3n9SPPuV0mK/i/nqabtmv75kAAAAABJRU5ErkJggg==', Locked = true;
        CurrentUsersEmailAddressTok: Label 'Current User''s Email Address', MaxLength = 250;
        CurrentUserTok: Label 'Current User', MaxLength = 250;

    procedure Send(EmailMessage: Codeunit "Email Message"; AccountId: Guid)
    var
        EmailOutlookAPIHelper: Codeunit "Email - Outlook API Helper";
    begin
        EmailOutlookAPIHelper.Send(EmailMessage);
    end;

    procedure RegisterAccount(var EmailAccount: Record "Email Account"): Boolean
    var
        EmailOutlookAPIHelper: Codeunit "Email - Outlook API Helper";
        CurrentUserEmailAccount: Page "Current User Email Account";
    begin
        EmailOutlookAPIHelper.SetupAzureAppRegistration();

        CurrentUserEmailAccount.RunModal();
        exit(CurrentUserEmailAccount.GetAccount(EmailAccount));
    end;

    procedure ShowAccountInformation(AccountId: Guid);
    var
        EmailOutlookAccount: Record "Email - Outlook Account";
    begin
        EmailOutlookAccount.SetRange("Outlook API Email Connector", Enum::"Email Connector"::"Current User");

        if EmailOutlookAccount.FindFirst() then
            Page.RunModal(Page::"Current User Email Account", EmailOutlookAccount);
    end;

    procedure GetAccounts(var EmailAccount: Record "Email Account")
    var
        EmailOutlookAPIHelper: Codeunit "Email - Outlook API Helper";
    begin
        EmailOutlookAPIHelper.GetAccounts(Enum::"Email Connector"::"Current User", EmailAccount);
        SubstituteEmailAddress(EmailAccount);
    end;

    local procedure SubstituteEmailAddress(var EmailAccount: Record "Email Account")
    var
        User: Record User;
        EmailOutlookAPIHelper: Codeunit "Email - Outlook API Helper";
        EnvironmentInformation: Codeunit "Environment Information";
        APIClient: interface "Email - Outlook API Client";
        OAuthClient: interface "Email - OAuth Client";
        CurrentUserName: Text[250];
        CurrentUserEmail: Text[250];

        [NonDebuggable]
        AccessToken: Text;
    begin
        // there may only be one account of type "Current User"
        if not EmailAccount.FindFirst() then
            exit;

        if EnvironmentInformation.IsSaaS() then begin
            if not User.Get(UserSecurityId()) then
                exit;
            if User."Authentication Email" = '' then
                exit;

            EmailAccount."Email Address" := User."Authentication Email";
        end else begin
            EmailOutlookAPIHelper.InitializeClients(APIClient, OAuthClient);

            if not EmailOutlookAPIHelper.IsAzureAppRegistrationSetup() then
                exit;
            if not OAuthClient.TryGetAccessToken(AccessToken) then
                exit;
            if not APIClient.GetAccountInformation(AccessToken, CurrentUserEmail, CurrentUserName) then
                exit;

            EmailAccount."Email Address" := CurrentUserEmail;
        end;
        EmailAccount.Modify();
    end;

    procedure DeleteAccount(AccountId: Guid): Boolean
    var
        EmailOutlookAPIHelper: Codeunit "Email - Outlook API Helper";
    begin
        exit(EmailOutlookAPIHelper.DeleteAccount(AccountId));
    end;

    procedure GetDescription(): Text[250]
    begin
        exit(ConnectorDescriptionTxt);
    end;

    procedure GetLogoAsBase64(): Text
    begin
        exit(CurrentUserConnectorBase64LogoTxt);
    end;

    procedure GetCurrentUsersAccountEmailAddress(): Text[250]
    begin
        exit(CurrentUsersEmailAddressTok)
    end;

    procedure GetCurrentUserAccountName(): Text[250]
    begin
        exit(CurrentUserTok)
    end;
}