// 区块链+积分
contract Points{

	// 会员积分模型
	struct Jf{
		uint total;
		uint lock;
		uint useable;
	}
	// 会员信息
	struct Vip{
		bool isregister;
		uint mobileid;
		mapping(uint=>Jf) points;
	}
	// 交易信息
	struct Trans{
		uint fmobileid; // 发布手机号码
		uint fmerid;
		uint fpoints;
		uint tmerid;
		uint tpoints;
		uint tmobileid; // 交易手机号码
		uint state; // 0-等待交易,2-成功,4-取消
		uint transtime;
		uint intime;
	}

	mapping(uint=>Vip) tvips; // temporary
	mapping(uint=>Vip) vips;
	Trans[] transArray;
	uint[] mers; // 积分转移使用
	
	// 测试事件
	event Log(string _method, string _message, bool _result);

	function Points(){
		// 初始化商户数据
		mers.push(1234); // 1234-联动
		mers.push(1235); // 1235-腾讯
		mers.push(1236); // 1236-阿里
	}
	
	// 会员注册
	function register(uint mobileid) returns(bool result){
		Vip vip = vips[mobileid];
		if (vip.isregister){
			Log('REGISTER', '当前用户已注册', false);
			return false;
		}
		vip.isregister = true;
		vip.mobileid = mobileid;
		
		Vip tvip = tvips[mobileid];
		if (tvip.isregister){
			// mapping类型不支持'='号进行转移
			vip.isregister = true;
			vip.mobileid = mobileid;
			uint length = mers.length;
			for (uint index = 0; index < length; index++){
				uint merid = mers[index];
				vip.points[merid] = tvip.points[merid];
			}
			Log('REGISTER', '会员积分转移', true);
		}
		vips[mobileid] = vip;
		Log('REGISTER', '注册成功', true);
		return true;
	}
	
	// 会员积分查询
	function queryPoints(uint mobileid, uint merid) returns(uint total, uint lock, uint useable){
		Vip vip = vips[mobileid];
		if (!vip.isregister){
			Log('QUERYPOINTS', '非注册会员，不能进行积分查询', false);
			throw;
		}
		
		Jf jf = vip.points[merid];
		Log('QUERYPOINTS', '会员积分查询成功', true);
		
		return (jf.total, jf.lock, jf.useable);
	}
	
	// 会员积分累计
	function earnpoints(uint mobileid, uint merid, uint points) public returns(bool result){
		Vip vip = vips[mobileid];
		if (vip.isregister){
			Jf jf = vip.points[merid];
			jf.total += points;
			jf.useable += points;
		
			vip.points[merid] = jf;
			vips[mobileid] = vip;
			Log('EARNPOINTS', '已注册会员积分累计成功', true);

		} else {
			Vip tvip = tvips[mobileid];
			tvip.isregister = true;
			tvip.mobileid = mobileid;
			Jf tjf = tvip.points[merid];
			tjf.total  += points;
			tjf.useable += points;

			tvip.points[merid] = tjf;
			tvips[mobileid] = tvip;
			Log('EARNPOINTS', '未注册会员积分累计成功', true);
		}
		
		return true;
	}
	
	// 会员积分消兑
	function costpoints(uint mobileid, uint merid, uint points) returns(bool result){
		Vip vip = vips[mobileid];
		if (vip.isregister){
			Jf jf = vip.points[merid];
			if (jf.useable < points){
				Log('COSTPOINTS', '已注册会员积分余额不足', false);
				return false;
			}
			jf.total -= points;
			jf.useable -= points;
		
			vip.points[merid] = jf;
			vips[mobileid] = vip;
		} else {
			Vip tvip = tvips[mobileid];
			if (!tvip.isregister){
				Log('COSTPOINTS', '用户不存在', false);
				return false;
			}
			Jf tjf = tvip.points[merid];
			if (tjf.useable < points){
				Log('COSTPOINTS', '非注册会员，积分余额不足', false);
				return false;
			}
			tjf.total -= points;
			tjf.useable -= points;
			tvip.points[merid] = tjf;
			vips[mobileid] = tvip;
		}
		
		Log('COSTPOINTS', '积分消兑成功', true);
		return true;
	}
	
	// 会员积分交易发布（含交易自动撮合）
	function issueTrans(uint mobileid, uint fmerid, uint fpoints, uint tmerid, uint tpoints) returns(bool result){
		if ((fmerid == tmerid) || (fpoints == 0) || (tpoints == 0)){
			Log('ISSUETRANS', '请求参数错误', false);
			return false;
		}
		Vip vip = vips[mobileid];
		if (!vip.isregister){
			Log('ISSUETRANS', '非注册会员不能发布交易', false);
			return false;
		}
		Jf jf = vip.points[fmerid];
		if (jf.useable < fpoints){
			Log('ISSUETRANS', '会员可用积分不足', false);
			return false;
		}
		jf.useable -= fpoints;
		jf.lock += fpoints;
		vip.points[fmerid] = jf;
		vips[mobileid] = vip;
		
		uint length = transArray.length++;
		
		transArray[length] = Trans({fmobileid:mobileid, 
								fmerid:fmerid, 
								fpoints: fpoints, 
								tmerid: tmerid,
								tpoints: tpoints,
								tmobileid: 0,
								state: 0,
								transtime: now,
								intime: now});

		Log('ISSUETRANS', '会员积分交易发布成功', true);
		return true;
	}

    // 会员积分分布取消
	function cancelTrans(uint mobileid, uint index) returns(bool result){
		Vip vip = vips[mobileid];
		if (!vip.isregister){
			Log('CANCELTRANS', '非注册会员不能取消交易', false);
			return false;
		}
		uint length = transArray.length;
		if(length <= index){
			Log('CANCELTRANS', '参数错误：数组下标越界', false);
			return false;
		}
		uint state = transArray[index].state;
		if (state == 2){
			Log('CANCELTRANS', '交易已成交不能取消', false);
			return false;
		}
		if (state == 4){
			Log('CANCELTRANS', '交易已取消不能再次取消', false);
			return false;
		}
		
		// 回滚积分
		uint fmerid = transArray[index].fmerid;
		uint fpoints = transArray[index].fpoints;
		
		vip.points[fmerid].lock -= fpoints;
		vip.points[fmerid].useable += fpoints;
		vips[mobileid] = vip;
		
		transArray[index].state = 4;
		transArray[index].transtime = now;
		
		Log('CANCELTRANS', '会员积分交易取消成功', true);
		return true;
	}
	
	// 获取交易数据长度
	function getTransLength() returns(uint length){
		return transArray.length;
	}
	
    // 获取积分交易明细
	function getTransinf(uint index) returns(uint fmobileid, uint fmerid, 
				uint fpoints, uint tmerid, uint tpoints, uint tmobileid, 
				uint state, uint transtime, uint intime){
		uint length = transArray.length;
		if (index >= length ){
			Log('GETTRANSINF', '参数错误：数组下标越界', false);
			throw;
		}
		Trans trans = transArray[index];
		Log('GETTRANSINF', '积分交易明细数据获取成功', true);
		return (trans.fmobileid, trans.fmerid, trans.fpoints, 
				trans.tmerid, trans.tpoints, trans.tmobileid, 
				trans.state, trans.transtime, trans.intime);
	}

	// 会员自助选择交易撮合
	function subTrans(uint mobileid, uint index) returns(bool result){
		// !important
		Vip rvip = vips[mobileid];
		if (!rvip.isregister){
			Log('SUBTRANS', '非注册会员不能进行积分交易', false);
			return false;
		}
		uint length = transArray.length;
		if (index >= length){
			Log('SUBTRANS', '参数错误：数组下标越界', false);
			return false;
		}
		Trans trans = transArray[index];
		
		uint state = trans.state;
		if (state == 2 || state == 4){
			Log('SUBTRANS', '当前交易异常', false);
			return false;
		}
		
		Vip lvip = vips[trans.fmobileid];
		Jf lfjf = lvip.points[trans.fmerid];
		Jf ltjf = lvip.points[trans.tmerid];
		Jf rfjf = rvip.points[trans.fmerid];
		Jf rtjf = rvip.points[trans.tmerid];
		
		if (rtjf.useable >= trans.tpoints){
			
			// set trans data
			transArray[index].tmobileid = mobileid;
			transArray[index].state = 2;
			transArray[index].transtime = now;
			
			// The left vip's jf
			lfjf.total -= trans.fpoints;
			lfjf.lock -= trans.fpoints;
			lvip.points[trans.fmerid] = lfjf;

			ltjf.total += trans.tpoints;
			ltjf.useable += trans.tpoints;
			lvip.points[trans.tmerid] = ltjf;

			vips[trans.fmobileid] = lvip;

			// The right vip's jf
			rfjf.total += trans.fpoints;
			rfjf.useable += trans.fpoints;
			rvip.points[trans.fmerid] = rfjf;

			rtjf.total -= trans.tpoints;
			rtjf.useable -= trans.tpoints;
			rvip.points[trans.tmerid] = rtjf;

			vips[mobileid] = rvip;

			Log('SUBTRANS', '积分交易撮合成功', true);
			return true;
		}
		Log('SUBTRANS', '会员可用积分不足，交易失败', false);
		return false;
	}
	
	function(){
		throw;
	}
}
