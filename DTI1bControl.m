%% Network Control analysis 
%Structural Brain Network Controllability Relates to Human Intelligence
%Anderson et al. 2023

%Turns off warnings
warning off all

g= readtable('/home/barbeylab/Public/MatlabScripts/1b/DTI/G_CFA_Scores_DTI.csv');

DTIsubs =  load('/home/barbeylab/Public/MatlabScripts/1b/DTI/Pre_DTI_Subnums.mat');

subnums=table;
for i = 1:size(filelist,1)
    subnums.Pre_Subnums(i)=regexp(filelist.name{i},'\d{4}','match');
end

subListPre=subnums.Pre_Subnums';
 


for i = 1:82
    disp(i)
    model=fitlm(foo,'G~ROI+Age+Sex','CategoricalVars',{'Sex'});
     %model=fitlm(foo,'G~ROI');
    pVals.ROIGAvg(i,1)=model.Coefficients.pValue(end);
    pVals.FitGAvg(i,1)=model.Rsquared.Adjusted;
    foo2=anova(model,'summary');
    pVals.ModelGAvg(i,1)=foo2.pValue(2);
    
     foo.ROI=squeeze(ModalControl{1}(i,1,ismember(subListPre,foo.Subject)));
         model=fitlm(foo,'G~ROI+Age+Sex','CategoricalVars',{'Sex'});
    pVals.ROIGMod(i,1)=model.Coefficients.pValue(end);
    pVals.FitGMod(i,1)=model.Rsquared.Adjusted;
    foo2=anova(model,'summary');
    pVals.ModelGMod(i,1)=foo2.pValue(2);
    
        model=fitlm(foo,'G~ROI');
     pVals.ROIGBn(i,1)=model.Coefficients.pValue(end);
    pVals.FitGBn(i,1)=model.Rsquared.Adjusted;
    foo2=anova(model,'summary');
    pVals.ModelGBn(i,1)=foo2.pValue(2);
end
[h, p]=fdr_bh(pVals.ROIGAvg)
[h, p]=fdr_bh(pVals.ROIGMod)
[h, ~]=fdr_bh(pVals.ROIGBn)

pVals.FDRGAvg=fdr_bh(pVals.ROIGAvg)
pVals.FDRGMod=fdr_bh(pVals.ROIGMod)
pVals.FDRGBn=fdr_bh(pVals.ROIGBn)


ROINames(pVals.FDRGAvg,1)
ROINames(pVals.FDRGMod,1)
ROINames(pVals.FDRGBn,1)


ROINames(pVals.FDRGAvg,1)
find(pVals.FDRGAvg==1)
pVals.FitGAvg(pVals.FDRGAvg) 
pVals.ModelGAvg(pVals.FDRGAvg) 
pVals.ROIGAvg(pVals.FDRGAvg)


ROINames(pVals.FDRGMod,1)
find(pVals.FDRGMod==1)
pVals.FitGMod(pVals.FDRGMod) 
pVals.ModelGMod(pVals.FDRGMod) 
pVals.ROIGMod(pVals.FDRGMod)


%% betweenness 
G=CON{1}.CIJ_W_Sym;
E=find(G); G(E)=1./G(E);
[~,idx] = maxk(betweenness_wei(G),10);
[~,idxrank] = sort(betweenness_wei(G));
find(idxrank==20)

[~,idx2] = maxk(eigenvector_centrality_und(CON{1}.CIJ_W_Sym),9);
[~,idxrank2] = sort(eigenvector_centrality_und(CON{1}.CIJ_W_Sym),'descend');

 Avg = ave_control(CON{1}.CIJ_W_Sym);
[~,idxrank] = sort(Avg);
idxrank(find(contains(ROINames.ROIName,'ctx_inferiorparietal')))

 
   ModalControlRC{1}(:,1,s) = modal_control(AllConnectome_AllSubjects(idx,idx,s));
   [h,~]=community_louvain(AllConnectome_AllSubjects(idx,idx,s));
      n  = size(AllConnectome_AllSubjects(idx,idx,s),1);             % number of nodes
      M  = 1:n;                   % initial community affiliations
      Q0 = -1; Q1 = 0;            % initialize modularity values
       while Q1-Q0>1e-5           % while modularity increases
           Q0 = Q1;                % perform community detection         
           [h,gbd] = community_louvain(AllConnectome_AllSubjects(idx,idx,s), [], M);
       end
   BoundControlRC{1}(:,1,s) = bound_control(AllConnectome_AllSubjects(idx,idx,s),.5,h)';

for s = 1:size(subListPre,1)
    disp(subListPre(s))
   AvgControlRC{1}(:,1,s) = ave_control(AllConnectome_AllSubjects(idx,idx,s));
   ModalControlRC{1}(:,1,s) = modal_control(AllConnectome_AllSubjects(idx,idx,s));
   [h,~]=community_louvain(AllConnectome_AllSubjects(idx,idx,s));
      n  = size(AllConnectome_AllSubjects(idx,idx,s),1);             % number of nodes
      M  = 1:n;                   % initial community affiliations
      Q0 = -1; Q1 = 0;            % initialize modularity values
       while Q1-Q0>1e-5           % while modularity increases
           Q0 = Q1;                % perform community detection         
           [h,gbd] = community_louvain(AllConnectome_AllSubjects(idx,idx,s), [], M);
       end
   BoundControlRC{1}(:,1,s) = bound_control(AllConnectome_AllSubjects(idx,idx,s),.5,h)';
end


for i = 1:9
    disp(i)
   foo.ROI=squeeze(AvgControlRC{1}(i,1,ismember(subListPre,foo.Subject))); 
   %foo.ROI=squeeze(AvgControl{1}(i,1,ismember(subListPre,foo.Subject)))./normAvgControl(i,ismember(subListPre,foo.Subject))';
    model=fitlm(foo,'Gf~ROI+Age+Sex','CategoricalVars',{'Sex'});
     %model=fitlm(foo,'Gf~ROI');
    pVals.ROIGfAvg(i,1)=model.Coefficients.pValue(end);
    pVals.FitGfAvg(i,1)=model.Rsquared.Adjusted;
    foo2=anova(model,'summary');
    pVals.ModelGfAvg(i,1)=foo2.pValue(2);
   model=fitlm(foo,'Gc~ROI+Age+Sex','CategoricalVars',{'Sex'});
       pVals.ROIGcAvg(i,1)=model.Coefficients.pValue(end);
    pVals.FitGcAvg(i,1)=model.Rsquared.Adjusted;
    foo2=anova(model,'summary');
    pVals.ModelGcAvg(i,1)=foo2.pValue(2);
     model=fitlm(foo,'G~ROI+Age+Sex','CategoricalVars',{'Sex'});
    pVals.ROIGAvg(i,1)=model.Coefficients.pValue(end);
    pVals.FitGAvg(i,1)=model.Rsquared.Adjusted;
    foo2=anova(model,'summary');
    pVals.ModelGAvg(i,1)=foo2.pValue(2);
    
     foo.ROI=squeeze(ModalControlRC{1}(i,1,ismember(subListPre,foo.Subject)));
    %foo.ROI=squeeze(ModalControl{1}(i,1,ismember(subListPre,foo.Subject)))./normModalControl(i,ismember(subListPre,foo.Subject))';
    model=fitlm(foo,'Gf~ROI+Age+Sex','CategoricalVars',{'Sex'});
    pVals.ROIGfMod(i,1)=model.Coefficients.pValue(end);
    pVals.FitGfMod(i,1)=model.Rsquared.Adjusted;
    foo2=anova(model,'summary');
    pVals.ModelGfMod(i,1)=foo2.pValue(2);
   model=fitlm(foo,'Gc~ROI+Age+Sex','CategoricalVars',{'Sex'});
       pVals.ROIGcMod(i,1)=model.Coefficients.pValue(end);
    pVals.FitGcMod(i,1)=model.Rsquared.Adjusted;
    foo2=anova(model,'summary');
    pVals.ModelGcMod(i,1)=foo2.pValue(2);
         model=fitlm(foo,'G~ROI+Age+Sex','CategoricalVars',{'Sex'});
    pVals.ROIGMod(i,1)=model.Coefficients.pValue(end);
    pVals.FitGMod(i,1)=model.Rsquared.Adjusted;
    foo2=anova(model,'summary');
    pVals.ModelGMod(i,1)=foo2.pValue(2);
    
     foo.ROI=squeeze(BoundControlRC{1}(i,1,ismember(subListPre,foo.Subject)));
     %foo.ROI=squeeze(BoundControl{1}(i,1,ismember(subListPre,foo.Subject)))./normBoundControl(i,ismember(subListPre,foo.Subject))';
    %model=fitlm(foo,'Gf~ROI+Age+Sex','CategoricalVars',{'Sex'});
    %pVals.ROIGfBn(i,1)=model.Coefficients.pValue(end);
    %pVals.FitGfBn(i,1)=model.Rsquared.Adjusted;
    %foo2=anova(model,'summary');
    %pVals.ModelGfBn(i,1)=foo2.pValue(2);
    [holdmatrix1,holdmatrix2]=partialcorr([foo.Gf,foo.ROI,foo.Age,foo.Sex],'Type','Spearman');
    pVals.FitGfBn(i,1)=holdmatrix1(1,2)^2;
    pVals.ROIGfBn(i,1)=holdmatrix2(1,2);
   %model=fitlm(foo,'Gc~ROI+Age+Sex','CategoricalVars',{'Sex'});
    %pVals.ROIGcBn(i,1)=model.Coefficients.pValue(end);
    %pVals.FitGcBn(i,1)=model.Rsquared.Adjusted;
    %foo2=anova(model,'summary');
    %pVals.ModelGcBn(i,1)=foo2.pValue(2);
     [holdmatrix1,holdmatrix2]=partialcorr([foo.Gc,foo.ROI,foo.Age,foo.Sex],'Type','Spearman');
    pVals.FitGcBn(i,1)=holdmatrix1(1,2)^2;
    pVals.ROIGcBn(i,1)=holdmatrix2(1,2);
    %model=fitlm(foo,'G~ROI+Age+Sex','CategoricalVars',{'Sex'});
    %pVals.ROIGBn(i,1)=model.Coefficients.pValue(end);
    %pVals.FitGBn(i,1)=model.Rsquared.Adjusted;
    %foo2=anova(model,'summary');
    %pVals.ModelGBn(i,1)=foo2.pValue(2);
     [holdmatrix1,holdmatrix2]=partialcorr([foo.G,foo.ROI,foo.Age,foo.Sex],'Type','Spearman');
    pVals.FitGBn(i,1)=holdmatrix1(1,2)^2;
    pVals.ROIGBn(i,1)=holdmatrix2(1,2);
end
[h, p]=fdr_bh(pVals.ROIGfAvg(1:9))
[h, p]=fdr_bh(pVals.ROIGfMod(1:9))
[h, p]=fdr_bh(pVals.ROIGfBn(1:9))
[h, p]=fdr_bh(pVals.ROIGcAvg(1:9))
[h, p]=fdr_bh(pVals.ROIGcMod(1:9))
[h, p]=fdr_bh(pVals.ROIGcBn(1:9))
[h, p]=fdr_bh(pVals.ROIGAvg(1:9))
[h, p]=fdr_bh(pVals.ROIGMod(1:9))
[h, p]=fdr_bh(pVals.ROIGBn(1:9))

pVals.FDRGfAvg=fdr_bh(pVals.ROIGfAvg(1:9))
pVals.FDRGfMod=fdr_bh(pVals.ROIGfMod(1:9))
pVals.FDRGfBn=fdr_bh(pVals.ROIGfBn(1:9))

pVals.FDRGcAvg=fdr_bh(pVals.ROIGcAvg(1:9))
pVals.FDRGcMod=fdr_bh(pVals.ROIGcMod(1:9))
pVals.FDRGcBn=fdr_bh(pVals.ROIGcBn(1:9))


pVals.FDRGAvg=fdr_bh(pVals.ROIGAvg(1:9))
pVals.FDRGMod=fdr_bh(pVals.ROIGMod(1:9))
pVals.FDRGBn=fdr_bh(pVals.ROIGBn(1:9))

ROINames(pVals.FDRGfAvg,1)
ROINames(pVals.FDRGfMod,1)
ROINames(pVals.FDRGfBn,1)

ROINames(pVals.FDRGcAvg,1)
ROINames(pVals.FDRGcMod,1)
ROINames(pVals.FDRGcBn,1)

ROINames(pVals.FDRGAvg,1)
ROINames(pVals.FDRGMod,1)
ROINames(pVals.FDRGBn,1)


ROINames(pVals.FDRGfMod,1)
find(pVals.FDRGfMod==1)
pVals.FitGfMod(pVals.FDRGfMod) 
pVals.ModelGfMod(pVals.FDRGfMod) 
pVals.ROIGfMod(pVals.FDRGfMod)


%% edge betweenness lesion ing
% not reported in paper
sampleavg=ave_control(CON{1}.CIJ_W_Sym);
G=CON{1}.CIJ_W_Avg;
E=find(G); G(E)=1./G(E);
E=edge_betweenness_wei(G);
E=E(:);
[~,idx] = maxk(E,672);
G=CON{1}.CIJ_W_Sym;
G(idx)=0;
samplelesionavg=ave_control(G);

SampleAvgDiff=samplelesionavg-sampleavg;

SampleAvgDiffP=SampleAvgDiff./sampleavg*100;

G=CON{1}.CIJ_W_Sym;
E=find(G); G(E)=1./G(E);
[~,idx2] = maxk(betweenness_wei(G),10);
[~,idxrank2] = sort(betweenness_wei(G),'descend');
find(idxrank==14) ;

%% information-weighted controllability metric
% not reported in paper
G=CON{1}.CIJ_W_Sym;
E=find(G); G(E)=1./G(E);
[sr, PL_bin, PL_wei, PL_dis, paths]=navigation_wu(G,distance_wei_floyd(CON{1}.CIJ_W_Sym,'inv'))

hold=mean_first_passage_time(CON{1}.CIJ_W_Sym) ;
hold2=ave_control(CON{1}.CIJ_W_Sym);
hold2=hold2./max(hold2(:));
E=mean([hold(:,:);hold(:,:)']);
E=E./max(E(:));

E=[];
for s = 1:size(subListPre,1)
    disp(subListPre(s))
   holdfoo=ave_control(AllConnectome_AllSubjects(:,:,s));
   hold2(:,s)=holdfoo./max(holdfoo(:));
   holdfoo=efficiency_wei(AllConnectome_AllSubjects(:,:,s),1);
   %holdfoo=mean([holdfoo(:,:);holdfoo(:,:)']);
   E(:,s)=holdfoo./max(holdfoo(:));
end
hold2(:,s)./E(:,s) ;

for i = 1:82
    disp(i)
   foo.ROI=squeeze(E(i,ismember(subListPre,foo.Subject))./hold2(i,ismember(subListPre,foo.Subject)))';
    model=fitlm(foo,'Gf~ROI+Age+Sex','CategoricalVars',{'Sex'});
     %model=fitlm(foo,'Gf~ROI');
    pVals.ROIGfAvg(i,1)=model.Coefficients.pValue(end);
    pVals.FitGfAvg(i,1)=model.Rsquared.Adjusted;
    foo2=anova(model,'summary');
    pVals.ModelGfAvg(i,1)=foo2.pValue(2);
   model=fitlm(foo,'Gc~ROI+Age+Sex','CategoricalVars',{'Sex'});
       pVals.ROIGcAvg(i,1)=model.Coefficients.pValue(end);
    pVals.FitGcAvg(i,1)=model.Rsquared.Adjusted;
    foo2=anova(model,'summary');
    pVals.ModelGcAvg(i,1)=foo2.pValue(2);
     model=fitlm(foo,'G~ROI+Age+Sex','CategoricalVars',{'Sex'});
    pVals.ROIGAvg(i,1)=model.Coefficients.pValue(end);
    pVals.FitGAvg(i,1)=model.Rsquared.Adjusted;
    foo2=anova(model,'summary');
    pVals.ModelGAvg(i,1)=foo2.pValue(2);
end



pVals.FDRGfAvg=fdr_bh(pVals.ROIGfAvg)

pVals.FDRGcAvg=fdr_bh(pVals.ROIGcAvg)

pVals.FDRGAvg=fdr_bh(pVals.ROIGAvg)

ROINames(pVals.ROIGfAvg,1)
find(pVals.ROIGfAvg==1)
pVals.FitGfMod(pVals.ROIGfAvg) 
pVals.ModelGfMod(pVals.ROIGfAvg) 
pVals.ROIGfMod(pVals.ROIGfAvg)

G=CON{1}.CIJ_W_Sym;
E=find(G); G(E)=G(E)/max(max(G));
efficiency_wei(CON{1}.CIJ_W_Sym,1)
getCommunicability

for i = 1%:size(subListPre,1)
squeeze(AvgControl{1}(i,1,ismember(subListPre,foo.Subject)))
end

