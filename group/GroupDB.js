var instance = null;
export default class GroupDB {
    static getInstance() {
        if (!instance) {
            instance = new GroupDB()
        }
        return instance;
    }
    
    constructor() {
        
    }

    setDB(db) {
        this.db = db;
        console.log("set db....");
    }

    insertGroup(group) {
        var self = this;
        var p = new Promise(function(resolve, reject) {
            self.db.transaction((tx) => {
                resolve(tx);
            });
        });
        return p.then((tx) => {
            var p1 = new Promise(function(resolve, reject) {
                tx.executeSql('INSERT INTO `group` (id, name, master, timestamp) VALUES (?, ?, ?, ?)',
                              [group.id, group.name, group.master, group.timestamp],
                              function(tx, result) {
                                  console.log("insert result:", result);
                                  resolve(result.insertId);
                              },
                              function(tx, error) {
                                  reject(error);
                                  //rollback
                                  return false;
                              });   
            });

            var ps = group.members.map((m) => {
                return new Promise(function(resolve, reject) {
                    tx.executeSql('INSERT INTO `group_member` (group_id, member_id) VALUES (?, ?)',
                                  [group.id, m.uid],
                                  function(tx, result) {
                                      console.log("insert result:", result);
                                      resolve(result.insertId);
                                  },
                                  function(tx, error) {
                                      reject(error);
                                      //rollback
                                      return false;
                                  });   
                });
            });
            ps = ps.concat(p1);
            return Promise.all(ps);
        });
    }

    getGroups() {
        var self = this;
        var p = new Promise(function(resolve, reject) {
            self.db.executeSql('SELECT g.id, g.name, g.master, g.timestamp, g.sync_key as syncKey FROM `group` as g',
                               [],
                               function(result) {
                                   var groups = [];
                                   for (var i = 0; i < result.rows.length; i++) {
                                       var row = result.rows.item(i);
                                       groups.push(row);
                                   }
                                   resolve(groups);
                               },
                               function(error) {
                                   reject(error);
                               });
        });
        return p;
    }
    
    getGroup(groupID) {
        var self = this;
        var p = new Promise(function(resolve, reject) {
            self.db.executeSql('SELECT m.group_id, m.member_id, g.name, g.master, g.timestamp, g.sync_key as syncKey FROM group_member as m, `group` as g WHERE m.group_id=? AND m.group_id = g.id',
                            [groupID],
                            function(result) {
                                var group = {};
                                var members = [];
                                for (var i = 0; i < result.rows.length; i++) {
                                    var row = result.rows.item(i);
                                    group.name = row.name;
                                    group.id = row.group_id;
                                    group.master = row.master;
                                    group.timestamp = row.timestamp;
                                    members.push({uid:row.member_id});
                                }

                                group.members = members;

                                resolve(group);
                            },
                            function(error) {
                            });
        });
        return p;
    }

    addGroupMember(groupID, memberID) {
        var self = this;
        var p = new Promise(function(resolve, reject) {
            self.db.executeSql('INSERT INTO group_member (group_id, member_id) VALUES(?, ?)',
                               [groupID, memberID],
                               function(result) {
                                   resolve();
                               },
                               function(error) {
                                   reject(error);
                               });
        });
        return p;        
    }

    removeGroupMember(groupID, memberID) {
        var self = this;
        var p = new Promise(function(resolve, reject) {
            self.db.executeSql('DELETE FROM group_member WHERE group_id=? AND member_id=?',
                               [groupID, memberID],
                               function(result) {
                                   resolve();
                               },
                               function(error) {
                                   reject(error);
                               });
        });
        return p;                
    }

    updateName(groupID, name) {
        var self = this;
        var p = new Promise(function(resolve, reject) {
            self.db.executeSql('UPDATE `group` SET name=? WHERE id=?',
                               [name, groupID],
                               function(result) {
                                   resolve();
                               },
                               function(error) {
                                   reject(error);
                               });
        });
        return p;            
    }

    updateSyncKey(groupID, syncKey) {
        var self = this;
        var p = new Promise(function(resolve, reject) {
            self.db.executeSql('UPDATE `group` SET sync_key=? WHERE id=?',
                               [name, syncKey],
                               function(result) {
                                   resolve();
                               },
                               function(error) {
                                   reject(error);
                               });
        });
        return p;         
    }
    
    disbandGroup(groupID) {
        
    }

}
