cordova.define("com.catchzeng.testplugin.testModel", function(require, exports, module) {
var exec = require("cordova/exec");

function TestModel() {};

TestModel.prototype.testPlugin = function (success,fail,option) {
     exec(success, fail, 'testPlugin', 'testWithTitle', option);
};

TestModel.prototype.getQposId = function (success,fail,option) {
    exec(success, fail, 'testPlugin', 'getQposId', option);
};
   
TestModel.prototype.scanQPos2Mode = function (success,fail,option) {
    exec(success, fail, 'testPlugin', 'scanQPos2Mode', option);
};
               
TestModel.prototype.connectBluetoothDevice = function (success,fail,option) {
    exec(success, fail, 'testPlugin', 'connectBluetoothDevice', option);
};
               
TestModel.prototype.doTrade = function (success,fail,option) {
    exec(success, fail, 'testPlugin', 'doTrade', option);
};

TestModel.prototype.disconnectBT = function (success,fail,option) {
    exec(success, fail, 'testPlugin', 'disconenctBT', option);
};

  var testModel = new TestModel();
  module.exports = testModel;
});
