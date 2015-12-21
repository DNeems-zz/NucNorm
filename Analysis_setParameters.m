function H=Analysis_setParameters(H,AnalysisMethod_Index)

H.Index_forAnalysis=CallBack_Value_String(H.CProps.MenuAddParm(end));
H.make_TwoD= get(H.AnProp(1).AnaProp(1),'value');
H.Analysis_Channels=arrayfun(@(x) get(x,'value'),H.CProps.MenuAddParm(2:end-1));
H.Ref_Menu=get(H.CProps.MenuAddParm(1),'string');
H.Referance_Channel=get(H.CProps.MenuAddParm(1),'value');
H.is_Pariwise=get(H.CProps.Pairwise,'value');
H.Cluster_Numbers=str2double(get(H.GS.Cluster_Num,'string'));
H.Cluster_Under=cell2mat(get(H.GS.Cluster_Under,'value'));
H.Cluster_Over=cell2mat(get(H.GS.Cluster_Over,'value'));


H.SaveDir=get(H.SavePathString,'string');
if get(H.AnProp(2).AnaProp(4),'value')==1
    H.NormType=2;
else
    H.NormType=1;
end

H.Use_Method=cell2mat(get(H.AnaMethod(AnalysisMethod_Index),'value'));
H.Method_Names=get(H.AnaMethod(AnalysisMethod_Index),'string');
H.Sim_Usage=cell2mat(get(H.AnProp(2).AnaProp(1:3),'value'));
H.useCentroid= get(H.AnProp(3).AnaProp(1),'value');
H.useTotal= get(H.AnProp(3).AnaProp(2),'value');
H.Among_ClusterNum=str2double(get(H.GS.Among_Num,'string'));
H.Usage.Among=cell2mat(get(H.GS.Among,'value'));
H.Usage.Within=cell2mat(get(H.GS.Within,'value'));

H.Simulation_Num=str2double(get(H.AnProp(4).AnaProp(2),'string'));
H.CI=str2double(get(H.AnProp(4).AnaProp(4),'string'));
H.Calc_SimError=get(H.AnProp(2).AnaProp(6),'value');
H.Funcs.Among=get(H.GS.Among(ismember(get(H.GS.Among,'visible'),'on')),'userdata');
H.Funcs.Within=get(H.GS.Within(ismember(get(H.GS.Within,'visible'),'on')),'userdata');
H.Num_Shell=str2double(get(H.AnaMethod(4),'string'));
H.Global_Within=get(H.GS.Within_Global,'value');
end