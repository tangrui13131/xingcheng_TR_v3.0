package com.xingchen.web.controller.system;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.xingchen.common.core.controller.BaseController;
import com.xingchen.common.core.domain.AjaxResult;
import com.xingchen.system.domain.SysPointsLog;
import com.xingchen.system.mapper.SysUserMapper;
import com.xingchen.system.service.ISysPointsLogService;

/**
 * 积分流水 信息操作处理
 * 
 * @author xingchen
 */
@RestController
@RequestMapping("/system/pointsLog")
public class SysPointsLogController extends BaseController
{
    @Autowired
    private ISysPointsLogService pointsLogService;

    @Autowired
    private SysUserMapper userMapper;

    /**
     * 每日打卡增加积分
     */
    @PostMapping("/checkIn")
    public AjaxResult checkIn()
    {
        Long userId = getUserId();
        int addPoints = 10;

        // 增加用户积分余额
        userMapper.updateUserPoints(userId, addPoints);

        // 记录积分流水：收入
        SysPointsLog pointsLog = new SysPointsLog();
        pointsLog.setUserId(userId);
        pointsLog.setOperateType(1);
        pointsLog.setSourceType(1);
        pointsLog.setPoints(addPoints);
        pointsLogService.insertSysPointsLog(pointsLog);

        // 返回最新余额
        int balance = pointsLogService.selectUserPointsBalance(userId);
        return success(balance);
    }

    /**
     * 查询当前用户积分余额
     */
    @GetMapping("/myPoints")
    public AjaxResult myPoints()
    {
        int balance = pointsLogService.selectUserPointsBalance(getUserId());
        return success(balance);
    }
}
