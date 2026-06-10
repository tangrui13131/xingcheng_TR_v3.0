package com.xingchen.system.service;

import java.util.List;
import com.xingchen.system.domain.SysPointsLog;

/**
 * 积分流水Service接口
 * 
 * @author xingchen
 */
public interface ISysPointsLogService 
{
    /**
     * 查询积分流水
     * 
     * @param id 积分流水主键
     * @return 积分流水
     */
    public SysPointsLog selectSysPointsLogById(Long id);

    /**
     * 查询积分流水列表
     * 
     * @param sysPointsLog 积分流水
     * @return 积分流水集合
     */
    public List<SysPointsLog> selectSysPointsLogList(SysPointsLog sysPointsLog);

    /**
     * 新增积分流水
     * 
     * @param sysPointsLog 积分流水
     * @return 结果
     */
    public int insertSysPointsLog(SysPointsLog sysPointsLog);

    /**
     * 修改积分流水
     * 
     * @param sysPointsLog 积分流水
     * @return 结果
     */
    public int updateSysPointsLog(SysPointsLog sysPointsLog);

    /**
     * 批量删除积分流水
     * 
     * @param ids 需要删除的积分流水主键集合
     * @return 结果
     */
    public int deleteSysPointsLogByIds(Long[] ids);

    /**
     * 删除积分流水信息
     * 
     * @param id 积分流水主键
     * @return 结果
     */
    public int deleteSysPointsLogById(Long id);

    /**
     * 查询用户积分余额
     * 
     * @param userId 用户ID
     * @return 积分余额
     */
    public int selectUserPointsBalance(Long userId);
}
