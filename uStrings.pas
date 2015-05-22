unit uStrings;
interface
const
    intFileIconIndex = 1;
    CrLf = sLineBreak;
    strDefaultExt = '.xml';
    strCryptedExt = '.opwd';
    strRootNode = 'Root';
    strHeaderNode = 'Header';
    strDataNode = 'Data';
    strFolderNode = 'Folder';
    strItemNode = 'Item';
    strDefItemNode = 'DefItem';
    strConfigFile = 'config.xml';
    strLink = 'https://github.com/Mrgnstrn/OmgPass/releases/';
    strSaveDialogDefFileName = 'NewCryptedBase';
    strBackupFilePrefix = 'Backup_';
    strBackupDTformat = 'yymmdd_hhmmss_';
    strDefaultBackupFolder = '.\Backups';
    strAssociateParam = 'fa';
    strDeassociateParam = 'dfa';

const arrFieldFormats: array[0..8] of String = ('title',
                                                'text',
                                                'pass',
                                                'web',
                                                'comment',
                                                'date',
                                                'mail',
                                                'file',
                                                '');

const arrNodeTypes: array[0..9] of String = ('root',
                                                'header',
                                                'data',
                                                'page',
                                                'folder',
                                                'deffolder',
                                                'item',
                                                'defitem',
                                                'field',
                                                '');

const arrDefFieldNames: array[0..8] of String = ('Title',
                                                    'Login',
                                                    'Password',
                                                    'Website',
                                                    'Comment',
                                                    'Date',
                                                    'Mail',
                                                    'File',
                                                    'Text or Login');

resourcestring
    rsFileTypeDescription = 'OmgPass crypted container';                              //Описание для файловой ассоциации
    rsFileTypeName = 'OmgPass.Crypted';
    rsTypes ='Title|Text|Pass|Link|Memo|Date|Mail|File';
    rsDefFieldNames = 'Title|Login|Password|Website|Comment|Date|Mail|File|Text or Login';
    rsTitleDefName = 'Title';
    rsTextDefName = 'Login';
    rsPassDefName = 'Password';
    rsCommentDefName = 'Comment';
    rsLinkDefName = 'Website';
    rsDateDefName = 'Date';
    rsMailDefName = 'Mail';
    rsFileDefName = 'File';
    //Название новой записи, папки, страницы
    rsNewItemTitle = 'New record';
    rsNewFolderTitle = 'New folder';
    rsNewPageTitle = 'Page';
    //Серый текст в поле поиска
    rsSearchText = 'Search';
    //Инфо блок для папок
    rsInfoTitle =           'Title: ';
    rsInfoSubfolders =      'Subfolders:       ';
    rsInfoTotalFolders =    'Total folders:    ';
    rsInfoSubItems =        'Subrecords:      ';
    rsInfoTotalItems =      'Total records:   ';
    //MessageBoxes
    rsDelFieldConfirmationText = 'Confirm to delete field "%s"?' + CrLf + 'Value will be deleted too';
    rsDelFieldConfirmationCaption = 'Deleting field';
    rsCantDelTitleField = 'Can''t delete unique title of record';
    //DeleteNode
    rsDelNodeTitle = 'Deleting';
    rsDelItem = 'Warning!' + CrLf + 'Are you sure you want to delete the record %s?';
    rsDelFolder ='Warning!' + CrLf + 'Are you sure you want to delete the folder %s?' +
                               CrLf + 'This will delete all subfolders and records!';
    rsDelPage = 'WARNING!' + CrLf + 'Are you sure you want to delete the page %s?' +
                                CrLf + 'This will delete all subfolders and records!!!' +
                                CrLf + 'CONFIRM DELETING?';
    rsCantDelPage =  'Sorry! Can''t delete unique page.';
//    rsChangeTitleWarningCaption = 'Deleting field';
//    rsChangeTitleWarning = 'Can''t change format for only title of record';
    rsFieldNotSelected = 'Field not selected';
    rsDemo = 'Sorry, you''ve reached the limit of the records count for the test version of program';
    rsDocumentIsEmpty = 'Hmm, it looks like your document is empty!' + CrLf +
                        'Before working with the document,' + CrLf +
                        'you must add at least one page.' + CrLf + CrLf +
                        'Would you like to do this?';
    rsDocumentIsEmptyTitle = 'Ooops!';
    //
    //Window captions
    //Заголовки окошек
    rsFrmAccountsCaption = ' welcomes you!';
    rsFrmAccountsCaptionOpen = 'Open base';
    rsFrmAccountsCaptionChange = ' - Document manager';
    rsFrmEditItemCaption = 'Edit record';
    rsFrmEditItemCaptionDef = 'Edit default record';
    rsFrmEditItemCaptionNew = 'New record';
    rsFrmEditFieldCaption = 'Edit field properties';
    rsFrmEditFieldCaptionNew = 'New field...';

    //Modal buttons
    //Модальные кнопочки
    rsClose = 'Close';
    rsCancel = 'Cancel';
    rsOK = 'OK';
    rsExit = 'Exit';
    rsOpen = 'Open';
    rsCopy = 'Copy';

    //Smart-buttons hints
    //Подсказки для кнопулек
    rsHintOpenLink = 'Open link';
    rsHintCopyToClipboard = 'Copy to clipboard';
    rsHintCopyFromClipboard = 'Copy from clipboard';
    rsHintGenerate = 'Generate password';
    rsHintEditField = 'Edit field properties';
    rsHintSaveFile = 'Save file(s)';
    rsHintAddFile = 'Add file(s)';

    //frmAccounts
    rsSaveDialogFilter = 'Omg!Pass Crypted files (*.opwd)|*.opwd|Omg!Pass XML files (*.xml)|*.xml';
    rsOpenDialogFilter = 'Omg!Pass Crypted files (*.opwd)|*.opwd|Omg!Pass XML files (*.xml)|*.xml|All files|*.*';
    rsOpenDialogFilterCryptedOnly = 'Omg!Pass Crypted (*.opwd)|*.opwd';
    rsCreateNewNeedFile = 'Please select location for new base' + CrLf + 'and type main password if it needed.';
    rsCreateNewNeedFileTitle = 'Can''t create new base';
    rsCreateNewWrongConfirm = 'Confirm field is not equal to password';
    rsCreateNewWrongConfirmTitle = 'Can''t create new base';
    rsFileNotFoundMsg = 'File not found on the stored path!' +
                         CrLf + 'Would you like to create a new document' +
                         CrLf + '%s ?';
    rsFileNotFoundMsgTitle = 'File not found';
    rsSaveDialogFileExists = 'You have selected an existing file:' + CrLf + '%s' + CrLf+ 'Overwrite it?';
    rsSaveDialogTitle = 'Save new document as...';
    rsOpenDialogTitle = 'Open document...';
    rsOpenDocumentError = 'Can''t open file' + CrLf + '%s' + CrLf + 'Please, make sure it is the correct file' + CrLf + '(Error class: %s)';
    rsOpenDocumentErrorTitle = 'Open document error';
    rsWrongPasswordError = 'Wrong or incorrect password! You can try again.' + CrLf + ' Please, check CapsLock and see on hint image';
    rsWrongPasswordErrorTitle = 'Wrong password';
    {rsDeletingDocument = 'Warning!' + CrLf +
                            'Are you sure you want to delete the document' + CrLf + '%s ?';
    rsDeletingDocumentTitle = 'Deleting...';}
    rsTxtPassFileNotFound = 'File not found';
    rsTxtPassFileNotSelected = 'File not selected';
    rsTxtPassFileIsBad = 'Bad or corupted file';
    rsTxtPassPassEmpty = 'Empty password used';
    rsTxtPassAlrOpened = 'File already opened';
    rsTxtPassPassNotReq = 'Not required';
    //frmMain
    rsAbout = '%s ver. %s' + CrLf +'An simple app for store and managment yours passwords' + CrLF +
                'Copyright by Nazarov Timur (vk.com/id1669165)'+ CrLf + CrLf +
                'Boomy icons by Milosz Wlazlo (miloszwl.deviantart.com)' + CrLf +
                'Class TRyMenu by Alexey Rumyancev (skitl@mail.ru)';
    rsAboutTitle = 'About...';
    //frmOptions
    rsCantCreateBackupFolder = 'Can''t create backup folder ';
    rsCantCreateBackup = 'Can''t create backup of ';
    rsSelectBackupDirectoryDialog = 'Select folder for backups...';
    rsWrongBackupFolderTitle = 'Wrong backup folder';
    rsWrongBackupFolder = 'Can''t find or create folder' + CrLf + '%s' + CrLf +
                          'Would you like set default folder?' + CrLf + CrLf +
                          'Yes - set default value' + CrLf +
                          'No - try another value' + CrLf +
                          'Cancel - set previous value';
    rsBackupHintTitle = 'Full path of backup folder:';
    //frmPassword
    rsWrongOldPassword = 'Wrong old password';
    rsWrongOldPasswordTitle = 'Error';
    rsWrongNewPassword = 'New password equals to old password';
    rsWrongNewPasswordTitle = 'Error';
    rsNewPasswordEmpty = 'Confirm using empty password?';
    rsNewPasswordEmptyTitle = 'New password is empty';
    rsWrongConfirmPassword = 'Wrong confirm password';
    rsWrongConfirmPasswordTitle = 'Error';
    rsPasswordChanged = 'Password has been succesfully changed!';
    rsPasswordChangedTitle = 'Excellent news';
    //frmGenerator
    rsGeneratorError = 'Selected set of characters and settings are not compatible!';
    rsGeneratorErrorTitle = 'Warning';

implementation
end.
