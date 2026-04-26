package com.xingchen.system.service.impl;

import java.util.Date;
import java.util.List;
import com.xingchen.common.exception.ServiceException;
import com.xingchen.common.utils.DateUtils;
import com.xingchen.common.utils.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.xingchen.system.domain.SysPointsLog;
import com.xingchen.system.domain.SysRedemption;
import com.xingchen.system.mapper.SysRedemptionMapper;
import com.xingchen.system.mapper.SysUserMapper;
import com.xingchen.system.service.ISysPointsLogService;
import com.xingchen.system.service.ISysRedemptionService;

/**
 * 积分兑换订单Service业务层处理
 * 
 * @author xingchen
 */
@Service
public class SysRedemptionServiceImpl implements ISysRedemptionService
{
    @Autowired
    private SysRedemptionMapper redemptionMapper;

    @Autowired
    private ISysPointsLogService pointsLogService;

    @Autowired
    private SysUserMapper userMapper;

    /**
     * 查询兑换订单列表
     * 
     * @param redemption 兑换订单
     * @return 兑换订单集合
     */
    @Override
    public List<SysRedemption> selectRedemptionList(SysRedemption redemption)
    {
        return redemptionMapper.selectRedemptionList(redemption);
    }

    /**
     * 根据ID查询兑换订单
     * 
     * @param id 兑换订单主键
     * @return 兑换订单
     */
    @Override
    public SysRedemption selectRedemptionById(Long id)
    {
        return redemptionMapper.selectRedemptionById(id);
    }

    /**
     * 用户提交兑换申请
     * 
     * @param redemption 兑换订单
     * @return 结果
     */
    @Override
    @Transactional
    public int submitRedemption(SysRedemption redemption)
    {
        Long userId = SecurityUtils.getUserId();

        // 查询并校验用户积分余额
        int balance = pointsLogService.selectUserPointsBalance(userId);
        if (balance < redemption.getPointsCost())
        {
            throw new ServiceException("积分余额不足，当前余额：" + balance + "，所需积分：" + redemption.getPointsCost());
        }

        redemption.setStatus("0");
        redemption.setApplyTime(DateUtils.getNowDate());
        redemption.setUserId(userId);
        int result = redemptionMapper.insertRedemption(redemption);

        // 扣减用户积分余额
        userMapper.updateUserPoints(userId, -redemption.getPointsCost());

        // 记录积分流水：支出
        SysPointsLog pointsLog = new SysPointsLog();
        pointsLog.setUserId(redemption.getUserId());
        pointsLog.setOperateType(2);
        pointsLog.setSourceType(3);
        pointsLog.setPoints(-redemption.getPointsCost());
        pointsLog.setReferenceId(redemption.getId());
        pointsLogService.insertSysPointsLog(pointsLog);

        return result;
    }

    /**
     * HR通过审核
     * 
     * @param id 兑换订单主键
     * @return 结果
     */
    @Override
    public int approveRedemption(Long id)
    {
        SysRedemption redemption = redemptionMapper.selectRedemptionById(id);
        if (redemption == null || !"0".equals(redemption.getStatus()))
        {
            throw new RuntimeException("订单不存在或状态不正确");
        }
        redemption.setStatus("1");
        redemption.setAuditTime(DateUtils.getNowDate());
        redemption.setAuditorId(SecurityUtils.getUserId());
        return redemptionMapper.updateRedemption(redemption);
    }

    /**
     * HR驳回审核
     * 
     * @param id 兑换订单主键
     * @param reason 驳回原因
     * @return 结果
     */
    @Override
    @Transactional
    public int rejectRedemption(Long id, String reason)
    {
        SysRedemption redemption = redemptionMapper.selectRedemptionById(id);
        if (redemption == null || !"0".equals(redemption.getStatus()))
        {
            throw new RuntimeException("订单不存在或状态不正确");
        }
        redemption.setStatus("2");
        redemption.setAuditTime(DateUtils.getNowDate());
        redemption.setAuditorId(SecurityUtils.getUserId());
        redemption.setRejectReason(reason);
        int result = redemptionMapper.updateRedemption(redemption);

        // 退还积分：增加用户积分余额
        userMapper.updateUserPoints(redemption.getUserId(), redemption.getPointsCost());

        // 退还积分：记录积分流水
        SysPointsLog pointsLog = new SysPointsLog();
        pointsLog.setUserId(redemption.getUserId());
        pointsLog.setOperateType(1);
        pointsLog.setSourceType(4);
        pointsLog.setPoints(redemption.getPointsCost());
        pointsLog.setReferenceId(redemption.getId());
        pointsLogService.insertSysPointsLog(pointsLog);

        return result;
    }

    /**
     * 查询用户自己的兑换记录
     * 
     * @param userId 用户ID
     * @return 兑换订单集合
     */
    @Override
    public List<SysRedemption> selectMyRedemptions(Long userId)
    {
        return redemptionMapper.selectRedemptionsByUserId(userId);
    }
}
