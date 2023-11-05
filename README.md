# WebDavSync

Bidirectional WebDAV file synchronization client for Android. It was primarily created for Nextcloud, has not been tested with other storage providers.

## How it works

For predictable behavior this truth table has been created:

| Remote  | Index   | Local   | Download | Delete  | Upload  | Index  | Reason                                                 |
| ------- | ------- | ------- | -------- | ------- | ------- | ------ | ------------------------------------------------------ |
| &check; | &cross; | &cross; | &check;  |         |         | Remote | Created on remote                                      |
| &cross; | &cross; | &check; |          |         | &check; | Local  | Created on local                                       |
| &check; | &cross; | &check; |          |         |         | Ask    | Created on both ends                                   |
| &cross; | &check; | &check; |          | &check; |         | Delete | Deleted on remote                                      |
| &check; | &check; | &cross; |          | &check; |         | Delete | Deleted on local                                       |
| &cross; | &check; | &cross; |          |         |         | Delete | Deleted on both ends                                   |
| old     | old     | new     |          |         | &check; | Local  | New version on local                                   |
| new     | old     | old     | &check;  |         |         | Remote | New version on remote                                  |
| old     | new     | new     |          |         | &check; | Local  | Remote has been rolled back                            |
| new     | new     | old     | &check;  |         |         | Remote | Local has been rolled back                             |
| old     | new     | old     |          |         |         | Remote | The file has been rolled back identically on both ends |
| differs | differs | differs |          |         |         | Ask    | The file has been changed independently on both ends   |

"Ask" means the user will be notified of the conflict and the file will be removed from index. This way if the user resolves the conflict and deletes the wrong file from one end, the file will be redownloaded/reuploaded.

## Screenshots

TBA

## TODO

- [x] File browser screen
- [x] Mappings
- [x] File synchronization
- [x] Credentials saving and editing
- [ ] Logging
- [ ] Folder synchronization
- [ ] File conflict notification
- [ ] Scheduled periodic sync
- [ ] Styles & theming

## Download

TBA
