function MappingOutputFolder=MapIlluminaToPuck(PuckName,BeadType,varargin)
%PuckName should be of the same form as in the pipeline functions, i.e.,
%Puck_YYMMDD_XX, where XX is the puck number
%OPTIONS:
%1) IlluminaRootFolder.
%2) OutputFolder
%3) IlluminaReadThreshold
%4) MaximumBarcodesToAnalyze
%5) PrimerNLigationSequence
%6) PrimerUPLigationSequence
%7) InverseLigationSequence
%8) WhichLigationsAreMissing
%9) NumBases
%10) ProcessedImageFolder

    SaveData=1;

    NumPar=12; %We assume that the missing ligation is Truseq-4 if you are doing 13.
    index = find(cellfun(@(x) (all(ischar(x)) || isstring(x))&&(string(x)=="NumPar"), varargin, 'UniformOutput', 1));
    if ~isempty(index)
        NumPar=varargin{index+1};
    end    
    
    NumLigations=20; %We assume that the missing ligation is Truseq-4 if you are doing 13.
    index = find(cellfun(@(x) (all(ischar(x)) || isstring(x))&&(string(x)=="NumLigations"), varargin, 'UniformOutput', 1));
    if ~isempty(index)
        NumLigations=varargin{index+1};
    end    
    
    BarcodeSequence=[1,2,3,4,0,5,0,6,0,7,8,9,10,11,0,12,0,13,0,14];
    index = find(cellfun(@(x) (all(ischar(x)) || isstring(x))&&(string(x)=="BarcodeSequence"), varargin, 'UniformOutput', 1));
    if ~isempty(index)
        BarcodeSequence=varargin{index+1};
    end
    
    NumBases = 14;
    index = find(cellfun(@(x) (all(ischar(x)) || isstring(x))&&(string(x)=="NumBases"), varargin, 'UniformOutput', 1));
    if ~isempty(index)
        NumBases=varargin{index+1};
    end

    PrimerNLigationSequence = [2, 7, 1, 6, 5, 4, 3]; %good for 14 ligations
    index = find(cellfun(@(x) (all(ischar(x)) || isstring(x))&&(string(x)=="PrimerNLigationSequence"), varargin, 'UniformOutput', 1));
    if ~isempty(index)
        PrimerNLigationSequence=varargin{index+1};
    end

    
    PrimerUPLigationSequence=[2, 7, 1, 6, 5, 4,3];
    index = find(cellfun(@(x) (all(ischar(x)) || isstring(x))&&(string(x)=="PrimerUPLigationSequence"), varargin, 'UniformOutput', 1));
    if ~isempty(index)
        PrimerUPLigationSequence=varargin{index+1};
    end

    InverseLigationSequence=[3,1,7,6,5,4,2,10,8,14,13,12,11,9]; %Good for both 13 and 14 ligations.
    index = find(cellfun(@(x) (all(ischar(x)) || isstring(x))&&(string(x)=="InverseLigationSequence"), varargin, 'UniformOutput', 1));
    if ~isempty(index)
        InverseLigationSequence=varargin{index+1};
    end

    WhichLigationsAreMissing=[1,2,3,4,5,6,7,8,9,10,11,12,13,14];
    index = find(cellfun(@(x) (all(ischar(x)) || isstring(x))&&(string(x)=="WhichLigationsAreMissing"), varargin, 'UniformOutput', 1));
    if ~isempty(index)
        WhichLigationsAreMissing=varargin{index+1};
    end

    
    IlluminaReadThreshold=10;
    index = find(cellfun(@(x) (all(ischar(x)) || isstring(x))&&(string(x)=="IlluminaReadThreshold"), varargin, 'UniformOutput', 1));
    if ~isempty(index)
        IlluminaReadThreshold=varargin{index+1};
    end

    ImageSize=6030;
    index = find(cellfun(@(x) (all(ischar(x)) || isstring(x))&&(string(x)=="ImageSize"), varargin, 'UniformOutput', 1));
    if ~isempty(index)
        ImageSize=varargin{index+1};
    end

    
    MaximumBarcodesToAnalyze=80000;
    index = find(cellfun(@(x) (all(ischar(x)) || isstring(x))&&(string(x)=="MaximumBarcodesToAnalyze"), varargin, 'UniformOutput', 1));
    if ~isempty(index)
        MaximumBarcodesToAnalyze=varargin{index+1};
    end
    
    OutputFolder=['C:\Users\sgr\Dropbox (MIT)\Project - SlideSeq\Pucks\Barcodes\',PuckName,'\'];
    index = find(cellfun(@(x) (all(ischar(x)) || isstring(x))&&(string(x)=="OutputFolder"), varargin, 'UniformOutput', 1));
    if ~isempty(index)
        OutputFolder=varargin{index+1};
    end
    
    ProcessedImageFolder=['D:\Slideseq\Processed\',PuckName,'\'];
    index = find(cellfun(@(x) (all(ischar(x)) || isstring(x))&&(string(x)=="ProcessedImageFolder"), varargin, 'UniformOutput', 1));
    if ~isempty(index)
        ProcessedImageFolder=varargin{index+1};
    end
   
    
    IlluminaRootFolder='D:\Slideseq\Illumina\';
    index = find(cellfun(@(x) (all(ischar(x)) || isstring(x))&&(string(x)=="IlluminaRootFolder"), varargin, 'UniformOutput', 1));
    if ~isempty(index)
        IlluminaRootFolder=varargin{index+1};
    end
    
    c=clock;
    mappingstarttimereadable=[num2str(c(2)),'-',num2str(c(3)),'_',pad(num2str(c(4)),2,'left','0'),pad(num2str(c(5)),2,'left','0')];

    dirmap=dir(IlluminaRootFolder);
    tmppuckname=char(PuckName);
    if string(tmppuckname(1:5))=="Puck_"
        PuckDate=[tmppuckname(6:end)];
    elseif string(tmppuckname(1:9))=="SLACPuck_"
        PuckDate=[tmppuckname(10:end)];
    end
    MatchingFiles=find((contains(string({dirmap.name}),string([PuckDate,'_'])) | contains(string({dirmap.name}),string([PuckDate,'.'])) | contains(string({dirmap.name}),string(replace([PuckDate,'.'],'-','_'))) | contains(string({dirmap.name}),string(replace([PuckDate,'_'],'-','_')))) & ~[dirmap.isdir]);
    if length(MatchingFiles)==1
        DGETable=readtable([IlluminaRootFolder,dirmap(MatchingFiles(1)).name],'ReadVariableNames',true);
    else
        disp('Illumina DGE file was either non-unique or not found')
        MappingOutputFolder="NA";
        return
    end

    mkdir([OutputFolder,'BeadMapping_',mappingstarttimereadable]);
    MappingOutputFolder=[OutputFolder,'BeadMapping_',mappingstarttimereadable,'\'];

    
    %Load in the CSV:


    %Special code if analyzing DGEs with the total transcript counts, rather than the breakdown by gene:
%    GeneNames=DGETable.Properties.VariableNames;
%    GeneNames=GeneNames(2:end);
%    if puck==1
%        IlluminaBarcodes=string(DGETable.CTATCATCCTCGN);
%    end
%    if puck==3
%        IlluminaBarcodes=string(DGETable.CCGTACCTACCTG);
%    end
%    if puck==2
%        IlluminaBarcodes=string(DGETable.CGGCAGCAGGAAC);
%    end
%    if puck==5
%        IlluminaBarcodes=string(DGETable.CTGCTTTTGCACT);
%    end
%    if puck==6
%        IlluminaBarcodes=string(DGETable.CCTCACCCCTTTC);
%    end
    %NORMAL CODE:
    IlluminaBarcodes=DGETable.Properties.VariableNames;
    IlluminaBarcodes=IlluminaBarcodes(2:end);
    if BeadType=="SLACBeads_1"||BeadType=="SLACBeads_1_RC" %this is a temporary fix for the SLACBeads DGE.
        GeneNames={"Counts"};
    else
        try
            GeneNames=string(DGETable.GENE);
        catch
            GeneNames=string(DGETable.Var1); %this is legacy        
        end
    end
    DGE=table2array(DGETable(:,2:end));
%    DGE=csvread([IlluminaRootFolder,PuckName,'\DGE.csv'],1,1);
    %Special code if analyzing the total # transcripts only DGE.
%    DGE=DGE';

    DGEallsums=sum(DGE,1);
    IlluminaBarcodesToAnalyze=min(length(find(DGEallsums>=IlluminaReadThreshold)),MaximumBarcodesToAnalyze);
    
    [sorted,sortindices]=sort(DGEallsums,'descend');
    DGESorted=DGE(:,sortindices(1:IlluminaBarcodesToAnalyze));
    IlluminaBarcodesDownsampled=IlluminaBarcodes(sortindices(1:IlluminaBarcodesToAnalyze));
    
    %Because we are only sequencing J bases after Truseq and UP, we cut out
    %the 8th J base after truseq.
    if string(BeadType)=="SLACBeads_1_RC" %Depending on whether this was a miseq or a nextseq, these barcodes may be reverse complemented.
        IlluminaBarcodesDownsampled=cellfun(@(x) seqrcomplement(x),IlluminaBarcodesDownsampled,'UniformOutput',false);
    end
    if string(BeadType)=="180402"
        IlluminaBarcodesDownsampled=cellfun(@(x) [x(1:7),x(9:15)],IlluminaBarcodesDownsampled,'UniformOutput',false);
    end
    
    if string(BeadType)=="BobMistake"
        IlluminaBarcodesDownsampled=cellfun(@(x) [x(1:7),x(9:14),'N'],IlluminaBarcodesDownsampled,'UniformOutput',false);
        BeadType='180402';
    end
    
    load([OutputFolder,'AnalysisOutputs-selected'],'Bead');
    if string(BeadType)=="SLACBeads_1"||string(BeadType)=="SLACBeads_1_RC"
        Illumina=MapLocationsFunTruseqSLAC1TT(MappingOutputFolder,Bead,IlluminaBarcodesDownsampled,PrimerNLigationSequence,NumBases,SaveData,PuckName);
    end
    
    if string(BeadType)=="180402"
        Illumina=MapLocationsFunTruseqUP14J(MappingOutputFolder,Bead,IlluminaBarcodesDownsampled,PrimerNLigationSequence,PrimerUPLigationSequence,NumBases,SaveData,PuckName,"NumPar",NumPar);
    end
    if string(BeadType)=="ReversePhase"
        Illumina=MapLocationsFunTruseqUP(MappingOutputFolder,Bead,IlluminaBarcodesDownsampled,PrimerNLigationSequence,PrimerUPLigationSequence,NumBases,SaveData,PuckName,"NumPar",NumPar);    
    end
    NumNearestBarcodes=[Illumina.NumNearestBarcodes];
    hammingdistances=[Illumina.HammingDistance];
    MappedLocations=[Illumina.MappedLocation];




    %We now want to invert the Illumina => SOLiD mapping. We want to find,
    %for each SOLiD barcode, how many Illumina barcodes map onto it at the minimum
    %Hamming distance.
    %I think we could just do this using the Unique function. 
    
    %we want to do this only over the set of illumina barcodes that have
    %one SOLiD partner
    
    %% Find mapping from SOLiD to Illumina mapping  
    
    %Note that everything in the Illumina structure is referenced to the
    %*unique* bead barcodes, so we have to do:
    [UniqueBeadBarcodes,BBFirstRef,BBOccCounts]=unique([Bead.Barcodes]);
    Bead=Bead(BBFirstRef);
    %This typically cuts out almost no beads
    
    %In the MapLocations function, whenever an illumina barcode has more
    %than one SOLiD partner, we only store the index of one of the
    %partners. This is not a problem here because we are only using
    %illumina barcodes with a unique partner.
    
    NumNearestBarcodes=[Illumina.NumNearestBarcodes];
    IlluminaUnique=Illumina(hammingdistances<=2 & NumNearestBarcodes==1);
    IlluminaBarcodesUnique=IlluminaBarcodesDownsampled(hammingdistances<=2 & NumNearestBarcodes==1);
    DGEUnique=DGESorted(:,hammingdistances<=2 & NumNearestBarcodes==1); %this is the same as DGEGoodBeads
    %The illumina barcodes that go in here have all been matched to a unique SOLiD
    %barcode at HD<=2. So each illumina barcode must show up in exactly one
    %bead. sum([MappedBeads.NumIlluminaBarcodes]) can only be less than
    %length(IlluminaBarcodesUnique) if barcodes dropout because a different barcode
    %is closer in edit space to the same bead.
    droppedbarcodes=cell(1,length(Bead));
    IndexOfMatchingIlluminaBarcodes=cell(1,length(Bead));
    MatchingIlluminaHDs=cell(1,length(Bead));
    NumMatchingIlluminaBarcodes=cell(1,length(Bead));
    parfor jl=1:length(Bead)
%        if floor(jl/1000)==jl/1000
%            disp(num2str(jl))
%        end
        matchingbarcodes=find([IlluminaUnique.IndexofBeadBarcode]==jl);
        if length(matchingbarcodes)==0
            NumMatchingIlluminaBarcodes{jl}=0;
            MatchingIlluminaHDs{jl}=0;            
            continue
        end
        minval=min([IlluminaUnique(matchingbarcodes).HammingDistance]);
        minindex=find([IlluminaUnique.HammingDistance]==minval & [IlluminaUnique.IndexofBeadBarcode]==jl);
        droppedbarcodes{jl}=length(matchingbarcodes)-length(minindex);
        NumMatchingIlluminaBarcodes{jl}=length(minindex);
        MatchingIlluminaHDs{jl}=minval;
        IndexOfMatchingIlluminaBarcodes{jl}=minindex;
    end
    figure(36)
    histogram(cell2mat(droppedbarcodes))
    title('For each SOLiD barcode, the number of Illumina Barcodes at greater than min HD')
    set(gca,'yscale','log');
    export_fig([MappingOutputFolder,'Report_',PuckName,'.pdf'],'-append');
    
    droppedbarcodes=sum(cell2mat(droppedbarcodes));
    NumMatchingIlluminaBarcodes=cell2mat(NumMatchingIlluminaBarcodes);
    MatchingIlluminaHDs=cell2mat(MatchingIlluminaHDs);
    %NOTE THAT THE INDEX HERE IS NOT THE INDEX IN THE DGE -- it's the index
    %in the DGE reordered by reads.
    MappedBeads=struct('Barcodes',{Bead.Barcodes},'Locations',{Bead.Locations},'Pixels',{Bead.Pixels},'HammingDistances',num2cell(MatchingIlluminaHDs),'NumIlluminaBarcodes',num2cell(NumMatchingIlluminaBarcodes),'IndexofIlluminaBarcode',IndexOfMatchingIlluminaBarcodes);

    
    %% Find bijective mapping from SOLiD to Illumina
    
    %In an ideal world, we would actually check how many reads each
    %MappedBead has. So if a given bead has two nearest neighbors, we can
    %check to make sure it's not a sequencing error.
    UniqueMappedBeads=MappedBeads([MappedBeads.NumIlluminaBarcodes]==1);
%    [UniqueMappedBeads(:).IlluminaBarcode]=deal(IlluminaBarcodesUnique([UniqueMappedBeads.IndexofIlluminaBarcode]));

    UniqueMappedDGE=DGEUnique(:,[UniqueMappedBeads.IndexofIlluminaBarcode]);
    UniqueMappedIlluminaBarcodes=IlluminaBarcodesUnique([UniqueMappedBeads.IndexofIlluminaBarcode]);
    %We are somehow losing 1000 illumina barcodes on this step, which is
    %weird because there are only 67 cases of a solid barcode mapping to
    %two illumina barcodes.
    if SaveData
        save([MappingOutputFolder,'MappedBeads.mat'],'MappedBeads','-v7.3')
        save([MappingOutputFolder,'BijectiveMapping.mat'],'UniqueMappedBeads','UniqueMappedDGE','UniqueMappedIlluminaBarcodes','GeneNames','-v7.3');
    end
    
    disp(['For puck ',PuckName,' there were ',num2str(length(UniqueMappedBeads)),' barcodes.'])

    
    %% Plot figures

    DGEsums=sum(UniqueMappedDGE,1);
    figure(10)
    histogram(DGEsums,1:10:1000)
    title('Total Transcripts per Barcode for Bijectively Mapped Barcodes')
    set(gca,'yscale','log');
    export_fig([MappingOutputFolder,'Report_',PuckName,'.pdf'],'-append');
    
    figure(7)
    clf
    for k=1:length(DGEsums)
        rectangle('Position',[UniqueMappedBeads(k).Locations(1),UniqueMappedBeads(k).Locations(2),5*DGEsums(k)/mean(DGEsums),5*DGEsums(k)/mean(DGEsums)],...
          'Curvature',[1,1], 'FaceColor','r')
    end
    title('Reads per bead for bijective barcodes')
    export_fig([MappingOutputFolder,'Report_',PuckName,'.pdf'],'-append');
    
    figure(13)
    clf
    hold on
    for k=1:3    
        subplot(1,3,k)
        HD2=find([Illumina.HammingDistance]==k-1);
        NumNearestBarcodes=[Illumina(HD2).NumNearestBarcodes];
        histogram(NumNearestBarcodes,1:1:5)
        set(gca,'yscale','log');
        if k==2
            title(['Num SOLiD barcodes matching each Illumina barcode - for HD 0, 1, 2.',num2str(k-1)]);
        end
    end
    export_fig([MappingOutputFolder,'Report_',PuckName,'.pdf'],'-append');
    
    
    
    
    figure(19)
    histogram([MappedBeads.NumIlluminaBarcodes],0:1:10);
    title('Number of Illumina Barcodes per SOLiD barcode')
    export_fig([MappingOutputFolder,'Report_',PuckName,'.pdf'],'-append');

    
    pixelsperbead=cellfun(@(x) length(x),{MappedBeads.Pixels});
    pixelsperbeadbij=cellfun(@(x) length(x),{UniqueMappedBeads.Pixels});    
    figure(15)
    clf
    histogram(pixelsperbead)
    title('Pixels per Unique SOLiD barcode')
    export_fig([MappingOutputFolder,'Report_',PuckName,'.pdf'],'-append');    
    
    figure(16)
    clf
    histogram(pixelsperbeadbij)
    title('Pixels per Bijective Pair')
    export_fig([MappingOutputFolder,'Report_',PuckName,'.pdf'],'-append');    
    
    figure(20)
    histogram([UniqueMappedBeads.HammingDistances],0:1:NumBases);
    title('Distribution of HD between Bead and Illumina Barcodes for Bijective Pairs')
    export_fig([MappingOutputFolder,'Report_',PuckName,'.pdf'],'-append');
    
    %plot the locations of SOLiD barcodes with matched illumina barcodes
    figure(22)
    clf
    hold on
    goodbeads=find([MappedBeads.NumIlluminaBarcodes]==1);
    BaseName=[ProcessedImageFolder,PuckName,'_Ligation_'];
    suffix='_Stitched';
    ROIHeight=ImageSize;
    ROIWidth=ImageSize;
    BeadImageMatchedBeads=false(ROIHeight,ROIWidth);
    %export_fig([OutputFolder,'Report_',PuckName,'.pdf'],'-append');
    for qr=1:length(goodbeads)
        BeadImageMatchedBeads(MappedBeads(goodbeads(qr)).Pixels)=true;
    end
    title('Beads mapped bijectively (Green) or not mapped (Red) to Illumina Barcodes');

    badbeads=find([MappedBeads.NumIlluminaBarcodes]==0);
    BaseName=[ProcessedImageFolder,PuckName,'_Ligation_'];
    suffix='_Stitched';
    BeadImageBadBeads=false(ROIHeight,ROIWidth);
    %export_fig([OutputFolder,'Report_',PuckName,'.pdf'],'-append');
    for qr=1:length(badbeads)
        BeadImageBadBeads(MappedBeads(badbeads(qr)).Pixels)=true;
    end
    BeadImageFinal=zeros(ROIHeight,ROIWidth,3);
    BeadImageFinal(:,:,2)=BeadImageMatchedBeads;
    BeadImageFinal(:,:,1)=BeadImageBadBeads;    
    imshow(BeadImageFinal)
    export_fig([MappingOutputFolder,'Report_',PuckName,'.pdf'],'-append');

    
    %Plot the locations of SOLiD barcodes lacking matched illumina barcodes
    figure(23)
    clf
    BaseName=[ProcessedImageFolder,PuckName,'_Ligation_'];
    suffix='_Stitched';
    BeadImageRandomBeads=false(ROIHeight,ROIWidth);
    %export_fig([OutputFolder,'Report_',PuckName,'.pdf'],'-append');
    for qr=1:min(2000,length(goodbeads))
        BeadImageRandomBeads(MappedBeads(goodbeads(qr)).Pixels)=true;
    end
    title('2000 Random Beads matched to Illumina Barcodes')
    imshow(BeadImageRandomBeads)

    
    ReadsPerBead=sum(UniqueMappedDGE,1);
    [ReadsSorted,SortingIndices]=sort(ReadsPerBead,'descend');
    SortedUniqueMappedBeads=UniqueMappedBeads(SortingIndices);

    figure(24)
    clf
    BaseName=[ProcessedImageFolder,PuckName,'_Ligation_'];
    suffix='_Stitched';
    BeadImageTopBeads=false(ROIHeight,ROIWidth);
    %export_fig([OutputFolder,'Report_',PuckName,'.pdf'],'-append');
    for qr=1:min(2000,length(SortedUniqueMappedBeads))
        BeadImageTopBeads(SortedUniqueMappedBeads(qr).Pixels)=true;
    end
    title('Top 2000 Beads matched to Illumina Barcodes versus 2000 random unmatched beads')
    BeadImageRandomBadBeads=false(ROIHeight,ROIWidth);
    %export_fig([OutputFolder,'Report_',PuckName,'.pdf'],'-append');
    for qr=1:min(2000,length(badbeads))
        BeadImageRandomBadBeads(MappedBeads(badbeads(qr)).Pixels)=true;
    end
    BeadImageFinal2=zeros(ROIHeight,ROIWidth,3);
    BeadImageFinal2(:,:,2)=BeadImageTopBeads;
    BeadImageFinal2(:,:,1)=BeadImageRandomBadBeads;    
    imshow(BeadImageFinal2)
    export_fig([MappingOutputFolder,'Report_',PuckName,'.pdf'],'-append');
    
    %we now just want to plot
    try
    if 1
    DentateMarkers=find(GeneNames=='Prox1'|GeneNames=='Npnt'|GeneNames=='C1ql2');
    DentateMarkerSum=sum(UniqueMappedDGE(DentateMarkers,:),1);
    CAMarkers=find(GeneNames=='Cck'|GeneNames=='Fibcd1'|GeneNames=='Pvrl3'|GeneNames=='Kcnq5');
    CAMarkerSum=sum(UniqueMappedDGE(CAMarkers,:),1);
    INMarkers=find(GeneNames=='Gad2'|GeneNames=='Gad1'|GeneNames=='Vip'|GeneNames=='Npy'|GeneNames=='Sst'|GeneNames=='Pvalb'|GeneNames=='Lhx6');
    INMarkerSum=sum(UniqueMappedDGE(INMarkers,:),1);
    figure(25)
    clf
    BeadImageDentate=false(ROIHeight,ROIWidth);
    BeadImageCA=false(ROIHeight,ROIWidth);
    BeadImageIN=false(ROIHeight,ROIWidth);
    for qr=1:length(UniqueMappedBeads)
        if DentateMarkerSum(qr)>=1
            BeadImageDentate(UniqueMappedBeads(qr).Pixels)=true;
        end
        if CAMarkerSum(qr)>=1
            BeadImageCA(UniqueMappedBeads(qr).Pixels)=true;
        end
        if INMarkerSum(qr)>=1
            BeadImageIN(UniqueMappedBeads(qr).Pixels)=true;
        end
    end
    imshow(BeadImageDentate)
    title('Red: Dentate; Green: CA fields; Blue: Interneuron')
    BeadImageFinal3=zeros(ROIHeight,ROIWidth,3);
    BeadImageFinal3(:,:,3)=BeadImageIN;
    BeadImageFinal3(:,:,2)=BeadImageCA;
    BeadImageFinal3(:,:,1)=BeadImageDentate;    
    imshow(BeadImageFinal3)
    export_fig([MappingOutputFolder,'Report_',PuckName,'.pdf'],'-append');
    end
    catch
        disp('Failed to find dentate markers in DGE.')
    end
    

    %% Plots of the base balance and errors in the Illumina-SOLiD mapping.
    %ALL PLOTS DISPLAYED THIS WAY ARE IN LIGATION ORDER, NOT SEQUENCE ORDER
    disp('NOTE: The following analysis depends on the number of ligations, the ligation sequence, and the bead structure, and may require modification.')
    %We want to make a plot of the color space balance for the final
    %mapped barcodes
    BaseBalanceBarcodes=[UniqueMappedBeads.Barcodes];
    %The base 5 representations of the basecalls are:
    BaseBalanceBase5Barcodes=cellfun(@(x) reverse(string(x)),{dec2base(BaseBalanceBarcodes,5,NumBases)},'UniformOutput',false);
    BaseBalanceBase5Barcodes=BaseBalanceBase5Barcodes{1};

    BaseBalanceMatrix=zeros(5,NumBases);
    for jp=1:NumBases
        testcmp0(jp)='0';
        testcmp1(jp)='1';
        testcmp2(jp)='2';
        testcmp3(jp)='3';
        testcmp4(jp)='4';
    end
    BaseBalanceMatrix(1,:)=sum(char(BaseBalanceBase5Barcodes)==testcmp0,1);
    BaseBalanceMatrix(2,:)=sum(char(BaseBalanceBase5Barcodes)==testcmp1,1);
    BaseBalanceMatrix(3,:)=sum(char(BaseBalanceBase5Barcodes)==testcmp2,1);
    BaseBalanceMatrix(4,:)=sum(char(BaseBalanceBase5Barcodes)==testcmp3,1);
    BaseBalanceMatrix(5,:)=sum(char(BaseBalanceBase5Barcodes)==testcmp4,1);
    figure(26)
    b=bar(BaseBalanceMatrix');
    b(1).FaceColor='k';
    b(2).FaceColor='b';
    b(3).FaceColor='g';
    b(4).FaceColor='y';
    b(5).FaceColor='r';
    title('Base balance per ligation for bijectively mapped barcodes - SOLiD');
    export_fig([MappingOutputFolder,'Report_',PuckName,'.pdf'],'-append');


    colorspacesequence={};
    for seqnum=1:length(UniqueMappedIlluminaBarcodes)
        seq=char(UniqueMappedIlluminaBarcodes(seqnum));
        if BeadType=="SLACPuck_1"||BeadType=="SLACPuck_1_RC"
            [PrimerNcolorspace,badflagN]=bs2cs(seq(1:12),PrimerNLigationSequence,'T','');
            PrimerUPcolorspace=[];
        end
        if BeadType=="ReversePhase"
            [PrimerNcolorspace,badflagN]=bs2cs(seq(1:6),PrimerNLigationSequence,'T','T');
            [PrimerUPcolorspace,badflagUP]=bs2cs(seq(7:13),PrimerUPLigationSequence,'A','');
        end
        if BeadType=="180402"
            [PrimerNcolorspace,badflagN]=bs2cs(seq(1:7),PrimerNLigationSequence,'T','T');
            [PrimerUPcolorspace,badflagUP]=bs2cs(seq(8:14),PrimerUPLigationSequence,'A','');            
        end
        tmptest=num2str(cat(2,PrimerNcolorspace,PrimerUPcolorspace));
        colorspacesequence{seqnum}=tmptest(~isspace(tmptest));
    end
    colorspacesequence=string(colorspacesequence);
    %The base 5 representations of the basecalls are:
%    BaseBalanceBase5Barcodes=cellfun(@(x) reverse(string(x)),{dec2base(BaseBalanceBarcodes,5,NumBases)},'UniformOutput',false);
%    BaseBalanceBase5Barcodes=BaseBalanceBase5Barcodes{1};

    BaseBalanceMatrix2=zeros(5,NumBases);
    for jp=1:NumBases
        testcmp0(jp)='0';
        testcmp1(jp)='1';
        testcmp2(jp)='2';
        testcmp3(jp)='3';
        testcmp4(jp)='4';
    end
    BaseBalanceMatrix2(1,:)=sum(char(colorspacesequence')==testcmp0,1);
    BaseBalanceMatrix2(2,:)=sum(char(colorspacesequence')==testcmp1,1);
    BaseBalanceMatrix2(3,:)=sum(char(colorspacesequence')==testcmp2,1);
    BaseBalanceMatrix2(4,:)=sum(char(colorspacesequence')==testcmp3,1);
    BaseBalanceMatrix2(5,:)=sum(char(colorspacesequence')==testcmp4,1);
    figure(27)
    b=bar(BaseBalanceMatrix2');
    b(1).FaceColor='k';
    b(2).FaceColor='b';
    b(3).FaceColor='g';
    b(4).FaceColor='y';
    b(5).FaceColor='r';
    
    title('Base balance per ligation for bijective barcodes expected from Illumina');
    export_fig([MappingOutputFolder,'Report_',PuckName,'.pdf'],'-append');    
    
    figure(28)
    b=bar(BaseBalanceMatrix2'-BaseBalanceMatrix');
    b(1).FaceColor='k';
    b(2).FaceColor='b';
    b(3).FaceColor='g';
    b(4).FaceColor='y';
    b(5).FaceColor='r';
    
    title('Base balance of Illumina minus base balance of SOLiD in color space');
    %This plot shows BIAS: it does not show number of errors. A 0 in this
    %plot indicates that there is no bias, not that there are no errors.
    export_fig([MappingOutputFolder,'Report_',PuckName,'.pdf'],'-append');    
    
    %this plot shows the actual errors. If there is disagreement between
    %Illumina and SOLiD, we plot the SOLiD barcode.
    ErrorMatrix=zeros(5,NumBases);
    ErrorBases=char(colorspacesequence')~=char(BaseBalanceBase5Barcodes);
    ErrorMatrix(1,:)=sum(char(colorspacesequence')==testcmp0 & ErrorBases,1);
    ErrorMatrix(2,:)=sum(char(colorspacesequence')==testcmp1 & ErrorBases,1);
    ErrorMatrix(3,:)=sum(char(colorspacesequence')==testcmp2 & ErrorBases,1);
    ErrorMatrix(4,:)=sum(char(colorspacesequence')==testcmp3 & ErrorBases,1);
    ErrorMatrix(5,:)=sum(char(colorspacesequence')==testcmp4 & ErrorBases,1);
    figure(29)
    b=bar(ErrorMatrix');
    b(1).FaceColor='k';
    b(2).FaceColor='b';
    b(3).FaceColor='g';
    b(4).FaceColor='y';
    b(5).FaceColor='r';

    title('Solid Color Expected on Mismatched Ligations');
    export_fig([MappingOutputFolder,'Report_',PuckName,'.pdf'],'-append');    

    figure(291)
    b=bar(sum(ErrorBases,1));
    title('Number of mismatched ligations, per base')
    export_fig([MappingOutputFolder,'Report_',PuckName,'.pdf'],'-append');    

    %% Output barcodes to CSV in for quality checking afterwards
    %NOTE: All barcodes outputted this way are in SEQUENCE ORDER, NOT IN
    %ORDER BY LIGATION

    %Bijective Pairs: SOLiD side
    UniqueBeadBarcodesForExport=char(replace(BaseBalanceBase5Barcodes,{'0','1','2','3','4'},{'N','B','G','O','R'}));
    if NumBases<14 %This is to deal with the InverseLigationSequence -- the export barcodes have to be 14 bases long
        UniqueBeadBarcodesForExport(:,NumBases+1:14)='N';
        UniqueBeadBarcodesForExport=UniqueBeadBarcodesForExport(:,WhichLigationsAreMissing);
    end
    UniqueBeadBarcodesForExport=UniqueBeadBarcodesForExport(:,InverseLigationSequence);
    %Bijective pairs: Illumina side
    UniqueIlluminaBarcodesForExport=char(replace(colorspacesequence',{'0','1','2','3','4'},{'N','B','G','O','R'}));
    if NumBases<14 %This is to deal with the InverseLigationSequence -- the export barcodes have to be 14 bases long
        UniqueIlluminaBarcodesForExport(:,NumBases+1:14)='N';
        UniqueIlluminaBarcodesForExport=UniqueIlluminaBarcodesForExport(:,WhichLigationsAreMissing);
    end
    UniqueIlluminaBarcodesForExport=UniqueIlluminaBarcodesForExport(:,InverseLigationSequence);
	    
    %All SOLiD beads passing filter
    AllBaseBalanceBarcodes=[Bead.Barcodes];
    %The base 5 representations of the basecalls are:
    BeadBarcodesForExport=cellfun(@(x) reverse(string(x)),{dec2base(AllBaseBalanceBarcodes,5,NumBases)},'UniformOutput',false);
    BeadBarcodesForExport=BeadBarcodesForExport{1};
    BeadBarcodesForExport=char(replace(BeadBarcodesForExport,{'0','1','2','3','4'},{'N','B','G','O','R'}));
    if NumBases<14 %This is to deal with the InverseLigationSequence -- the export barcodes have to be 14 bases long
        BeadBarcodesForExport(:,NumBases+1:14)='N';
        BeadBarcodesForExport=BeadBarcodesForExport(:,WhichLigationsAreMissing);
    end

    BeadBarcodesForExport=BeadBarcodesForExport(:,InverseLigationSequence);
    
    %All Illumina Barcodes >>> these are in order of the DGE
    Nseq='NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN';
    allilluminacolorspacesequence={};
    for seqnum=1:length(IlluminaBarcodesDownsampled)
        seq=char(IlluminaBarcodesDownsampled(seqnum));
        if length(seq)<13
            seq=Nseq(1:13);
        end
        if BeadType=="ReversePhase"
            [PrimerNcolorspace,badflagN]=bs2cs(seq(1:6),PrimerNLigationSequence,'T','T');
            [PrimerUPcolorspace,badflagUP]=bs2cs(seq(7:13),PrimerUPLigationSequence,'A','');
        end
        if BeadType=="180402"
            [PrimerNcolorspace,badflagN]=bs2cs(seq(1:7),PrimerNLigationSequence,'T','T');
            [PrimerUPcolorspace,badflagUP]=bs2cs(seq(8:14),PrimerUPLigationSequence,'A','');            
        end
        tmptest=num2str(cat(2,PrimerNcolorspace,PrimerUPcolorspace));
        allilluminacolorspacesequence{seqnum}=tmptest(~isspace(tmptest));
    end
%    isemptyfn=cell2mat(cellfun(@(x) ~isempty(x),allilluminacolorspacesequence,'UniformOutput',false));
    allilluminacolorspacesequence=string(allilluminacolorspacesequence);
    IlluminaBarcodesForExport=char(replace(allilluminacolorspacesequence',{'0','1','2','3','4'},{'N','B','G','O','R'}));
    if NumBases<14 %This is to deal with the InverseLigationSequence -- the export barcodes have to be 14 bases long
        IlluminaBarcodesForExport(:,NumBases+1:14)='N';
        IlluminaBarcodesForExport=IlluminaBarcodesForExport(:,WhichLigationsAreMissing);
    end
    IlluminaBarcodesForExport=IlluminaBarcodesForExport(:,InverseLigationSequence);
    
    save([MappingOutputFolder,'ReadableSequences.mat'],'UniqueBeadBarcodesForExport','UniqueIlluminaBarcodesForExport','BeadBarcodesForExport','IlluminaBarcodesForExport','-v7.3')
    csvwrite([MappingOutputFolder,'BijectiveBeadBarcodes.csv'],UniqueBeadBarcodesForExport);
    csvwrite([MappingOutputFolder,'BijectiveIlluminaBarcodes.csv'],UniqueIlluminaBarcodesForExport);
    csvwrite([MappingOutputFolder,'AllBeadBarcodes.csv'],BeadBarcodesForExport);
    csvwrite([MappingOutputFolder,'AnalyzedIlluminaBarcodes.csv'],IlluminaBarcodesForExport);

    coords=[UniqueMappedBeads.Locations]';
    barcode_locations = [UniqueMappedIlluminaBarcodes',mat2cell(coords(:,1),ones(size(coords,1),1)),mat2cell(coords(:,2),ones(size(coords,1),1))];
    barcode_locations = cell2table(barcode_locations, 'VariableNames',{'barcodes','xcoord','ycoord'});
    DGETable=array2table(UniqueMappedDGE,'VariableNames',UniqueMappedIlluminaBarcodes,'RowNames',cellstr(GeneNames'));
    writetable(barcode_locations, fullfile(OutputFolder,'BeadLocationsForR.csv'));
    writetable(DGETable, fullfile(OutputFolder,'MappedDGEForR.csv'),'WriteRowNames',true);
    
    %% Print output
    fileid=fopen([MappingOutputFolder,'Metrics.txt'],'a');
    fprintf(fileid,['\n\nThere were ',num2str(length(Bead)),' unique bead barcodes.\n',...
    'We analyzed ',num2str(IlluminaBarcodesToAnalyze),' Illumina barcodes with more than ',num2str(IlluminaReadThreshold),' reads.\n',...
    'There were ',num2str(length(IlluminaBarcodesUnique)),' Illumina barcodes uniquely matching a SOLiD barcode at HD<=2.\n',...
    'There were ',num2str(length(UniqueMappedIlluminaBarcodes)),' bijective pairings between SOLiD and Illumina barcodes.\n',...
    'A total of ',num2str(sum([MappedBeads([MappedBeads.NumIlluminaBarcodes]>1).NumIlluminaBarcodes])),' Illumina barcodes were dropped because multiple Illumina barcodes mapped onto a single SOLiD barcode.\n',...
    'A total of ',num2str(droppedbarcodes),' barcodes were dropped because the bead they mapped onto had another Illumina barcode that mapped onto it with lower Hamming distance.'
    ]);
    fclose(fileid);
