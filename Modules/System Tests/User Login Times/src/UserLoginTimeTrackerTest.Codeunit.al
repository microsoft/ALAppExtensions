// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 130044 "User Login Time Tracker Test"
{
    // Tests for the User Login Time Tracker codeunit

    Subtype = Test;
    Permissions = tabledata "User Login" = r,
                  tabledata "User Environment Login" = r;

    var
        LibraryAssert: Codeunit "Library Assert";
        UserLoginTimeTracker: Codeunit "User Login Time Tracker";
        UserLoginTestLibrary: Codeunit "User Login Test Library";
        PermissionsMock: Codeunit "Permissions Mock";

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestUserLoggedInEnvironment()
    var
        User: Record "User";
        UserSecId: Guid;
    begin
        // [GIVEN] A new user
        UserSecId := CreateGuid();
        User.Init();
        User."User Security ID" := UserSecId;
        User.Insert();

        PermissionsMock.Set('User Login View');

        // [WHEN] Checking whether the user has logged in before
        // [THEN] The result should be false, as the user is new and has never logged in
        LibraryAssert.IsFalse(UserLoginTimeTracker.UserLoggedInEnvironment(UserSecId), 'The user has logged in before');

        // [GIVEN] A User Login record corresponding to the new User
        UserLoginTestLibrary.InsertUserLogin(UserSecId, Today(), CurrentDateTime(), 0DT);

        // [WHEN] Checking whether the user has logged in before
        // [THEN] The result should be true
        LibraryAssert.IsTrue(UserLoginTimeTracker.UserLoggedInEnvironment(UserSecId), 'The user has not logged in before');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsFirstLogin()
    var
        User: Record "User";
        UserSecId: Guid;
        IsFirstLogin: Boolean;
    begin
        // [GIVEN] A new user
        UserSecId := CreateGuid();
        User.Init();
        User."User Security ID" := UserSecId;
        User.Insert();

        PermissionsMock.Set('User Login View');

        // [WHEN] Checking whether the current user has logged in before
        IsFirstLogin := UserLoginTimeTracker.IsFirstLogin(User."User Security ID");

        // [THEN] The result should be false, as the user is new and has never logged in
        LibraryAssert.IsTrue(IsFirstLogin, 'The user has never logged in before');

        // [GIVEN] A User Login record corresponding to the new User
        UserLoginTestLibrary.InsertUserLogin(UserSecId, 0D, CurrentDateTime(), 0DT);

        // [WHEN] Checking whether the current user has logged in before
        IsFirstLogin := UserLoginTimeTracker.IsFirstLogin(User."User Security ID");

        // [THEN] The result should be true
        LibraryAssert.IsFalse(IsFirstLogin, 'The user has logged in before');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestAnyUserLoggedInSinceDate()
    var
        UserLogin: Record "User Login";
        PastDate: Date;
        CurrentDate: Date;
        FutureDate: Date;
        AnyUserLoggedInSinceDate: Boolean;
    begin
        // [GIVEN] The User Login table is empty
        UserLogin.DeleteAll();

        PermissionsMock.Set('User Login View');

        // [GIVEN] Three dates - one in the past, one in the future, and one denoting the current date
        PastDate := CalcDate('<-1D>');
        CurrentDate := Today();
        FutureDate := CalcDate('<+2W>');

        // [WHEN] Checking if any user has logged in since any date
        AnyUserLoggedInSinceDate := UserLoginTimeTracker.AnyUserLoggedInSinceDate(PastDate);

        // [THEN] AnyUserLoggedInSinceDate should be false, since the User Login table is empty
        LibraryAssert.IsFalse(AnyUserLoggedInSinceDate, 'No user has logged in so far.');

        // [GIVEN] An entry in the User Login table with the "Last Login Date" set to the current date
        UserLoginTestLibrary.InsertUserLogin(UserSecurityId(), 0D, CreateDateTime(CurrentDate, 0T), 0DT);

        // [WHEN] Checking if any user has logged in since the past date
        AnyUserLoggedInSinceDate := UserLoginTimeTracker.AnyUserLoggedInSinceDate(PastDate);

        // [THEN] AnyUserLoggedInSinceDate should be true
        LibraryAssert.IsTrue(AnyUserLoggedInSinceDate, 'A user has logged in today.');

        // [WHEN] Checking if any user has logged in today
        AnyUserLoggedInSinceDate := UserLoginTimeTracker.AnyUserLoggedInSinceDate(CurrentDate);

        // [THEN] AnyUserLoggedInSinceDate should be true
        LibraryAssert.IsTrue(AnyUserLoggedInSinceDate, 'A user has logged in today.');

        // [WHEN] Checking if any user has logged since the future date
        AnyUserLoggedInSinceDate := UserLoginTimeTracker.AnyUserLoggedInSinceDate(FutureDate);

        // [THEN] AnyUserLoggedInSinceDate should be false
        LibraryAssert.IsFalse(AnyUserLoggedInSinceDate, 'No user can log in in the future.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestUserLoggedInSinceDateTime()
    var
        UserLogin: Record "User Login";
        PastDateTime: DateTime;
        CurrentDateTime: DateTime;
        FutureDateTime: DateTime;
        UserLoggedInSinceDateTime: Boolean;
    begin
        // [GIVEN] The User Login table is empty
        UserLogin.DeleteAll();

        PermissionsMock.Set('User Login View');

        // [GIVEN] Three dates - one in the past, one in the future, and one denoting the current date
        PastDateTime := CreateDateTime(CalcDate('<-1D>'), 0T);
        CurrentDateTime := CreateDateTime(Today(), 0T);
        FutureDateTime := CreateDateTime(CalcDate('<+2W>'), 0T);

        // [WHEN] Checking if any user has logged in since any date time
        UserLoggedInSinceDateTime := UserLoginTimeTracker.UserLoggedInSinceDateTime(PastDateTime);

        // [THEN] AnyUserLoggedInSinceDate should be false, since the User Login table is empty
        LibraryAssert.IsFalse(UserLoggedInSinceDateTime, 'The current user has not logged in so far.');

        // [GIVEN] An entry in the User Login table with the "Last Login Date" 
        // set to the past date and the user security different from the one of the current user's
        UserLoginTestLibrary.InsertUserLogin(CreateGuid(), 0D, PastDateTime, 0DT);

        // [WHEN] Checking if the current user has logged in since the past date
        UserLoggedInSinceDateTime := UserLoginTimeTracker.UserLoggedInSinceDateTime(PastDateTime);

        // [THEN] UserLoggedInSinceDateTime should be false
        LibraryAssert.IsFalse(UserLoggedInSinceDateTime, 'The current user has not logged in yet.');

        // [WHEN] Inserting a new entry in the User Login table for the current user, with the 
        // "Last Login Date" set to the current date
        UserLoginTestLibrary.InsertUserLogin(UserSecurityId(), 0D, CurrentDateTime, 0DT);

        // [WHEN] Checking if the current user has logged in today
        UserLoggedInSinceDateTime := UserLoginTimeTracker.UserLoggedInSinceDateTime(CurrentDateTime);

        // [THEN] AnyUserLoggedInSinceDate should be true
        LibraryAssert.IsTrue(UserLoggedInSinceDateTime, 'The user has logged in today.');

        // [WHEN] Checking if any user has logged since the future date
        UserLoggedInSinceDateTime := UserLoginTimeTracker.UserLoggedInSinceDateTime(FutureDateTime);

        // [THEN] AnyUserLoggedInSinceDate should be false
        LibraryAssert.IsFalse(UserLoggedInSinceDateTime, 'The user has not logged in since the specified date');

        // [WHEN] Checking if the current user has logged in since the past date
        UserLoggedInSinceDateTime := UserLoginTimeTracker.UserLoggedInSinceDateTime(PastDateTime);

        // [THEN] AnyUserLoggedInSinceDate should be true
        LibraryAssert.IsTrue(UserLoggedInSinceDateTime, 'The user has logged in today.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetPenultimateLoginDateTime()
    var
        UserLogin: Record "User Login";
        CurrentDate: DateTime;
        PenultimateLoginDateTime: DateTime;
    begin
        // [GIVEN] The User Login table is empty
        UserLogin.DeleteAll();

        PermissionsMock.Set('User Login View');

        // [WHEN] Getting the penultimate login date of the current user
        PenultimateLoginDateTime := UserLoginTimeTracker.GetPenultimateLoginDateTime();

        // [THEN] PenultimateLoginDateTime is 0DT, as no one has logged in yet
        LibraryAssert.AreEqual(0DT, PenultimateLoginDateTime, 'The User Login table is empty');

        // [GIVEN] The User Login contains an entry with the Penultimate Login Date as the current date 
        CurrentDate := CurrentDateTime();
        UserLoginTestLibrary.InsertUserLogin(UserSecurityId(), 0D, 0DT, CurrentDate);

        // [WHEN] Getting the penultimate login date of the current user
        PenultimateLoginDateTime := UserLoginTimeTracker.GetPenultimateLoginDateTime();

        // [THEN] PenultimateLoginDateTime is CurrentDate
        LibraryAssert.AreEqual(CurrentDate, PenultimateLoginDateTime, 'The penultimate login date is incorrect.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCreateOrUpdateLoginInfo()
    var
        UserLogin: Record "User Login";
        UserEnvironmentLogin: Record "User Environment Login";
    begin
        // [GIVEN] The User Login table is empty
        UserLoginTestLibrary.DeleteAllLoginInformation();

        PermissionsMock.Set('User Login View');

        // [WHEN] Calling CreateOrUpdateLoginInfo
        UserLoginTimeTracker.CreateOrUpdateLoginInfo();

        // [THEN] The User Login table should contain a single record (the one for the current test user)
        LibraryAssert.AreEqual(1, UserLogin.Count(), 'The User Login table should contain a single entry');

        LibraryAssert.IsTrue(UserLogin.Get(UserSecurityId()), 'There should be a User Login entry for the current user');

        // [THEN] The fields of the User Login table should be properly assigned	
        LibraryAssert.AreEqual(UserSecurityId(), UserLogin."User SID", 'The user security ID is incorrect');
        LibraryAssert.AreNotEqual(0D, UserLogin."First Login Date", 'The first login date should not be empty');
        LibraryAssert.AreEqual(0DT, UserLogin."Penultimate Login Date", 'The penultimate login date should be 0DT, as the user had only logged in once');
        LibraryAssert.AreNotEqual(0DT, UserLogin."Last Login Date", 'The last login date should not be empty');
        LibraryAssert.AreEqual(UserLogin."First Login Date", DT2Date(UserLogin."Last Login Date"), 'First login and Last login should be on the same date');

        // [THEN] The User Environment Login table should contain a single record (the one for the current test user)
        LibraryAssert.AreEqual(1, UserEnvironmentLogin.Count(), 'The User Environment Login table should contain a single entry');
        LibraryAssert.IsTrue(UserLogin.Get(UserSecurityId()), 'There should be a User Enviroment Login entry for the current user');

        // [WHEN] Calling CreateOrUpdateLoginInfo
        UserLoginTimeTracker.CreateOrUpdateLoginInfo();

        // [THEN] The User Login table should still contain a single record
        LibraryAssert.AreEqual(1, UserLogin.Count(), 'The User Login table should contain a single entry');

        LibraryAssert.IsTrue(UserLogin.Get(UserSecurityId()), 'There should be a User Login entry for the current user');

        // [THEN] The fields of the User Login table should be properly assigned	
        LibraryAssert.AreEqual(UserSecurityId(), UserLogin."User SID", 'The user security ID is incorrect');
        LibraryAssert.AreNotEqual(0D, UserLogin."First Login Date", 'The first login date should not be empty');
        LibraryAssert.AreNotEqual(0DT, UserLogin."Penultimate Login Date", 'The penultimate not be empty');
        LibraryAssert.AreNotEqual(0DT, UserLogin."Last Login Date", 'The last login date not be empty');

        // [THEN] The User Environment Login table should contain a single record (the one for the current test user)
        LibraryAssert.AreEqual(1, UserEnvironmentLogin.Count(), 'The User Environment Login table should contain a single entry');
        LibraryAssert.IsTrue(UserLogin.Get(UserSecurityId()), 'There should be a User Enviroment Login entry for the current user');
    end;
}
