#include<bits/stdc++.h>
using namespace std;

class graph {
	unordered_map<string, list<pair<string, int>> >m;
	unordered_map<string, unordered_map<string, string> >ids;
	map<int, list<pair<string, string>> > dist;
	unordered_set<string> optNodes;
	unordered_map<string, bool> visited;
	unordered_map<string,int>farDepth;
	int fixed_depth = -1;
	bool finalDepth = true;
	ofstream p;
	public:
		void insert(string id,int wt, string to, string from1, string from2=""){
			m[from1].push_back(make_pair(to, wt));
			ids[from1][to] = id;
			if(from2.length()){
			m[from2].push_back(make_pair(to, wt));
			ids[from2][to] = id;
			}
		}
		void print(){
		for(auto x:dist){
			cout<<x.first<<"-->";
			for(auto y: x.second){
				cout<<"("<<y.first<<","<<y.second<<") ";
			}
			cout<<endl;
			
		}}
		void timing(string cur,string sta, unordered_set<string> &ends, int sum, int &ans){
			if(ends.find(cur)!=ends.end()){
				sum = -sum;
				dist[sum].push_back(make_pair(sta, cur));
				return;
				
			}
			
			for(auto x: m[cur]){
				timing(x.first,sta, ends, sum+x.second,ans);
				ans = max(ans, sum+x.second);
			}
		}
		int driver(unordered_set<string> &s, unordered_set<string> &e){
			int ans=0;
			string t;
			for(auto x: s) {
				timing(x,x, e,0,ans);
			}
			return ans;
		}
		void optimize(string cur, string prev,string uskaprev, string e, int depth, int time, int target){
			if(cur==e) {
				//cout<<"Here"<<depth<<endl;
				if(farDepth.count(cur)){
					farDepth[cur] = max(depth, farDepth[cur]);
				}else{
					farDepth[cur] = depth;
				}
				return;
			}
			if(time>=target && finalDepth){
				fixed_depth = depth;
				//cout<<time<<" "<<target<<endl;
				//cout<<depth<<endl;
				finalDepth = false;
				optNodes.insert(ids[prev][cur]);
				cout<<"x"<<ids[prev][cur]<<" "<<time<<endl;
			}
			if(fixed_depth!=-1 && depth == fixed_depth){
				cout<<"y"<<ids[uskaprev][prev]<<" ";
				cout<<time<<" "<<depth<<endl;
				optNodes.insert(ids[prev][cur]);
			}
			if(farDepth.count(cur)){
					farDepth[cur] = max(depth, farDepth[cur]);
				}else{
					farDepth[cur] = depth;
				}
			for(auto x:m[cur]){
				if(!visited[x.first]){
					//cout<<depth<<" "<<target<<" "<<time<<endl;
					optimize(x.first, cur,prev, e, depth+1, time+x.second, target);
					visited[x.first] = true;
				}else{
					if(farDepth[x.first]>fixed_depth && depth<fixed_depth){
						cout<<"z"<<ids[cur][x.first]<<" "<<time<<endl;
						optNodes.insert(ids[cur][x.first]);
					}
				}
			}
		}
		void driver1(int target){
		bool finalDepth = true;
			for(auto x: dist){
				for(auto y: x.second){
					optimize(y.first, "", "",y.second, 0, 0, target);
					}
				}
			p.open("optmize_nodes.txt");
		for(auto x: optNodes){
			p<<x<<endl;
			}
			}
		}; 

int main(){
	graph g;
	string line;
	ifstream e;
	unordered_map<string, int> tpd;
	int dff[3];
	dff[0] =1;//tsetup
	dff[1] =1;//thold
	dff[2] =0.1;//c->q
	tpd["NOT"] = 1;
	tpd["NAND"] = 4;
	tpd["NOR"]=4;
	e.open("edges.txt");
	
	if(!e.is_open()){
		cout<<"error";
		return 0;
	}
	while(getline(e, line)){
		string arr[10];
		int idx = 0;
		int s = line.size();
		string word ="";
		for(int i=0; i<s; i++){
		if(line[i]==' '){
			if(word.size()>0){
				arr[idx++] = word;
			}
			word = "";
		}else{
			word = word+line[i];
		}
		}
		arr[idx] = word;
		if(arr[0]== "NOT"){
			
			g.insert(arr[1], tpd[arr[0]], arr[3], arr[2]);
		}else{
			
			g.insert(arr[1], tpd[arr[0]], arr[4], arr[2], arr[3]);
		}
	}
	e.close();
	e.open("launchCapture.txt");
	if(!e.is_open()){
		cout<<"error";
		return 0;
	}
	unordered_set<string>start;
	unordered_set<string>ends;
	while(getline(e, line)){
		
		string arr[10];
		int idx = 0;
		int s = line.size();
		string word ="";
		for(int i=0; i<s; i++){
		if(line[i]==' '){
			if(word.size()>0){
				arr[idx++] = word;
			}
			word = "";
		}else{
			word = word+line[i];
		}
		}
		arr[idx] = word;
		if(arr[0]=="input"){
			start.insert(arr[1]);
			
		}
		if(arr[0] =="output"){
			ends.insert(arr[1]);
		}if(arr[0]=="DFF"){
			if(ends.find(arr[3])!=ends.end()){
				ends.erase(ends.find(arr[3]));
			}else{
				start.insert(arr[3]);
			}
			ends.insert(arr[2]);
		}
	}
	e.close();
	int maxtime = g.driver(start, ends);
	int target = (maxtime/2);
	cout<<maxtime<<" "<<target<<endl;
	g.print();
	g.driver1(target);
	float total = (float)(maxtime+dff[0]+dff[2]);
	
	//g.print();
	ofstream x;
	x.open("output.txt");
	if(!x.is_open()){
		cout<<"error";
		return 0;
	}
	x<<1.0/total<<endl;
	x.close();
}	

