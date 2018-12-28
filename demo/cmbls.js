;(function(window){
    if (typeof window.CMBLS === "undefined") {
        window.CMBLS = {};
    }

    if (typeof window.CMBLS.DataPersistence !== "undefined") {
        var oldInstance = window.CMBLS.DataPersistence;
    }

    // 维护一个请求队列

    var requestMap = {
        
    }
    
    // 缓存旧的数据
    window.CMBLS.DataPersistence = {
        successCallback:function(id, message){
            var doc = $.parseXML(message);
            var action = $("Action",doc).text().toLowerCase();
            if(action !== "fuzzyget" && action !== "get"){
                return ;
            }
            try{
                var $data = $("Data>DataEnc",doc);
                var dataSets = $.parseXML("<DataEnc>" + Base64.decode($data.get(0).innerHTML) + "</DataEnc>");
                if(typeof requestMap[id].callback === "function"){
                    requestMap[id].callback(dataSets);
                }
            }catch(e){
                if(typeof requestMap[id].callback === "function"){
                    requestMap[id].callback(null,"xml解析错误");
                }
            }
            
            if(oldInstance && typeof oldInstance.successCallback === "function"){
                oldInstance.successCallback.call(this,id,message);
            }
        },
        failCallback:function(){
            
        }
    };

    var version = "1";
    var path = "http://CMBLS/DataPersistence";
    
    window.cacheManager = {
        set:function(option){
            var id = (new Date()).getTime();
            var parameters = $.extend({
                id: id,
                tag:"default",
                value:""
            });
            connectCmblsExecutor(version, path+"?id="+parameters.id+"&action=set&key=" + parameters.key + "&value=" + encodeURI(parameters.value) + "&tag=" + parameters.tag);
        },

        // 统一使用批量读取
        get:function(option){
            var id = (new Date()).getTime();
            var parameters = $.extend({
                id: id,
                tag:"default",
                callback:function(data,error){
                    
                }
            });
            connectCmblsExecutor(version, path+"?id="+parameters.id+"&action=FuzzyGet&tag=" + parameters.tag);
            requestMap[parameters.id] = parameters;
        }
    }

    // 调用方式
    // cacheManager.get({// 参数},function(){
    // })
})(window);