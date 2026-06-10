package com.xingchen.web.controller.system;

import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.xingchen.common.annotation.Log;
import com.xingchen.common.core.controller.BaseController;
import com.xingchen.common.core.domain.AjaxResult;
import com.xingchen.common.core.page.TableDataInfo;
import com.xingchen.common.enums.BusinessType;
import com.xingchen.system.domain.SysRedemption;
import com.xingchen.system.service.ISysPointsLogService;
import com.xingchen.system.service.ISysRedemptionService;

/**
 * 积分兑换订单 信息操作处理
 * 
 * @author xingchen
 */
@RestController
@RequestMapping("/system/redemption")
public class SysRedemptionController extends BaseController
{
    @Autowired
    private ISysRedemptionService redemptionService;

    @Autowired
    private ISysPointsLogService pointsLogService;

    /**
     * 用户提交兑换申请
     */
    @PostMapping("/submit")
    public AjaxResult submit(@RequestBody SysRedemption redemption)
    {
        return toAjax(redemptionService.submitRedemption(redemption));
    }

    /**
     * 获取兑换订单列表（HR分页查询）
     */
    @PreAuthorize("@ss.hasPermi('hr:redemption:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysRedemption redemption)
    {
        startPage();
        List<SysRedemption> list = redemptionService.selectRedemptionList(redemption);
        return getDataTable(list);
    }

    /**
     * 获取当前用户自己的兑换记录
     */
    @GetMapping("/myList")
    public AjaxResult myList()
    {
        List<SysRedemption> list = redemptionService.selectMyRedemptions(getUserId());
        return success(list);
    }

    /**
     * HR通过审核
     */
    @PreAuthorize("@ss.hasPermi('hr:redemption:audit')")
    @Log(title = "积分兑换审核", businessType = BusinessType.UPDATE)
    @PutMapping("/approve/{id}")
    public AjaxResult approve(@PathVariable Long id)
    {
        return toAjax(redemptionService.approveRedemption(id));
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

    /**
     * HR驳回审核
     */
    @PreAuthorize("@ss.hasPermi('hr:redemption:audit')")
    @Log(title = "积分兑换审核", businessType = BusinessType.UPDATE)
    @PutMapping("/reject/{id}")
    public AjaxResult reject(@PathVariable Long id, @RequestBody Map<String, String> params)
    {
        String reason = params.get("rejectReason");
        return toAjax(redemptionService.rejectRedemption(id, reason));
    }
}
