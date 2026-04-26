package com.xingchen.web.controller.system;

import java.util.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.xingchen.common.annotation.Log;
import com.xingchen.common.core.controller.BaseController;
import com.xingchen.common.core.domain.AjaxResult;
import com.xingchen.common.core.domain.entity.SysUser;
import com.xingchen.common.core.page.TableDataInfo;
import com.xingchen.common.enums.BusinessType;
import com.xingchen.system.domain.SysPointsLog;
import com.xingchen.system.mapper.SysPointsLogMapper;
import com.xingchen.system.mapper.SysUserMapper;
import com.xingchen.system.service.ISysUserService;

/**
 * 积分管理 信息操作处理
 * 
 * @author xingchen
 */
@RestController
@RequestMapping("/system/points")
public class SysPointsController extends BaseController
{
    @Autowired
    private ISysUserService userService;

    @Autowired
    private SysUserMapper userMapper;

    @Autowired
    private SysPointsLogMapper pointsLogMapper;

    /**
     * 分页查询用户积分列表
     */
    @PreAuthorize("@ss.hasPermi('hr:points:list')")
    @GetMapping("/userList")
    public TableDataInfo userList(SysUser user)
    {
        startPage();
        List<SysUser> list = userService.selectUserList(user);
        return getDataTable(list);
    }

    /**
     * 给指定用户增加100积分
     */
    @PreAuthorize("@ss.hasPermi('hr:points:add')")
    @Log(title = "积分管理", businessType = BusinessType.UPDATE)
    @PutMapping("/add/{userId}")
    public AjaxResult addPoints(@PathVariable Long userId)
    {
        // 更新用户积分余额
        userMapper.updateUserPoints(userId, 100);

        // 记录积分流水
        SysPointsLog log = new SysPointsLog();
        log.setUserId(userId);
        log.setOperateType(1);  // 1=收入
        log.setSourceType(5);   // 5=HR手动增加
        log.setPoints(100);
        log.setRemark("HR手动增加积分");
        log.setCreateTime(new Date());
        pointsLogMapper.insertSysPointsLog(log);

        return success();
    }
}
