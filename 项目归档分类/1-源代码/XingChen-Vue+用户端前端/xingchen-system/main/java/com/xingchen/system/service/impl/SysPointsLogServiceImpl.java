package com.xingchen.system.service.impl;

import java.util.List;
import com.xingchen.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.xingchen.system.mapper.SysPointsLogMapper;
import com.xingchen.system.domain.SysPointsLog;
import com.xingchen.system.service.ISysPointsLogService;

/**
 * 积分流水Service业务层处理
 * 
 * @author xingchen
 */
@Service
public class SysPointsLogServiceImpl implements ISysPointsLogService 
{
    @Autowired
    private SysPointsLogMapper sysPointsLogMapper;

    /**
     * 查询积分流水
     * 
     * @param id 积分流水主键
     * @return 积分流水
     */
    @Override
    public SysPointsLog selectSysPointsLogById(Long id)
    {
        return sysPointsLogMapper.selectSysPointsLogById(id);
    }

    /**
     * 查询积分流水列表
     * 
     * @param sysPointsLog 积分流水
     * @return 积分流水
     */
    @Override
    public List<SysPointsLog> selectSysPointsLogList(SysPointsLog sysPointsLog)
    {
        return sysPointsLogMapper.selectSysPointsLogList(sysPointsLog);
    }

    /**
     * 新增积分流水
     * 
     * @param sysPointsLog 积分流水
     * @return 结果
     */
    @Override
    public int insertSysPointsLog(SysPointsLog sysPointsLog)
    {
        sysPointsLog.setCreateTime(DateUtils.getNowDate());
        return sysPointsLogMapper.insertSysPointsLog(sysPointsLog);
    }

    /**
     * 修改积分流水
     * 
     * @param sysPointsLog 积分流水
     * @return 结果
     */
    @Override
    public int updateSysPointsLog(SysPointsLog sysPointsLog)
    {
        return sysPointsLogMapper.updateSysPointsLog(sysPointsLog);
    }

    /**
     * 批量删除积分流水
     * 
     * @param ids 需要删除的积分流水主键
     * @return 结果
     */
    @Override
    public int deleteSysPointsLogByIds(Long[] ids)
    {
        return sysPointsLogMapper.deleteSysPointsLogByIds(ids);
    }

    /**
     * 删除积分流水信息
     * 
     * @param id 积分流水主键
     * @return 结果
     */
    @Override
    public int deleteSysPointsLogById(Long id)
    {
        return sysPointsLogMapper.deleteSysPointsLogById(id);
    }

    /**
     * 查询用户积分余额
     * 
     * @param userId 用户ID
     * @return 积分余额
     */
    @Override
    public int selectUserPointsBalance(Long userId)
    {
        return sysPointsLogMapper.selectUserPointsBalance(userId);
    }
}
